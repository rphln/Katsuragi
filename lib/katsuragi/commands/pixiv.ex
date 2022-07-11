defmodule Katsuragi.Commands.Pixiv do
  @moduledoc """
  Sends a stamp.
  """

  use Percussion, :command

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  alias Katsuragi.Commands.Pixiv.Work
  alias Katsuragi.Commands.Pixiv.Constants

  @pattern ~r"pixiv\S*?/artworks/(\d+)(?:\s(\d+))?"i
  @blacklist ~r"blacklist: pixiv: (.+?)$"im

  def aliases do
    ["pixiv"]
  end

  def reply(message, gallery_id, page, blacklist) do
    with {:ok, work} <- Work.get(gallery_id),
         {:ok, pages} <- Work.pages(gallery_id),
         url <- Enum.at(pages, page, work),
         url <- url["urls"]["regular"],
         {:ok, file} <- Work.download(url) do
      name = Path.basename(url)

      is_blacklisted? =
        Enum.any?(
          work["tags"]["tags"],
          &(&1["translation"]["en"] in blacklist or &1["tag"] in blacklist)
        )

      description =
        work["tags"]["tags"]
        |> Enum.map(fn tag ->
          english = tag["translation"]["en"]
          japanese = tag["tag"]

          "[##{english || japanese}](https://www.pixiv.net/en/tags/#{japanese})"
        end)
        |> Enum.join("\u00A0\u00A0\t")

      icon = "https://s.pximg.net/common/images/apple-touch-icon.png"

      footer = """
      Gallery with #{work["pageCount"]} page(s).
      Shared by #{message.author.username}.
      """

      embed =
        %Embed{}
        |> Embed.put_color(0x0086E0)
        |> Embed.put_title(work["title"])
        |> Embed.put_author(work["userName"], Work.author_link_for(work), nil)
        |> Embed.put_description(description)
        # |> Embed.put_description("`#{description}`")
        |> Embed.put_footer(footer, icon)
        |> Embed.put_timestamp(Work.updated_at!(work))
        |> Embed.put_url(Work.link_for(work))

      if is_blacklisted? do
        embed =
          Embed.put_field(
            embed,
            "Note",
            "This gallery has one or more tags that were disallowed in this channel."
          )

        Api.create_message(message, embed: embed)
      else
        file = %{body: file.body, name: name}
        embed = Embed.put_image(embed, "attachment://#{name}")

        Api.create_message(message, file: file, embed: embed)
      end
    end
  end

  def call(%Request{message: message, channel_id: channel_id} = request) do
    channel = Nostrum.Api.get_channel!(channel_id)

    blacklist =
      with %{topic: topic} <- channel,
           [_match, blacklist] <- Regex.run(@blacklist, topic),
           {:ok, blacklist} <- Jason.decode(blacklist) do
        blacklist
      else
        _ -> []
      end

    matches =
      for match <- Regex.scan(@pattern, message.content) do
        {gallery_id, page} =
          case match do
            [_match, gallery_id] ->
              {gallery_id, 0}

            [_match, gallery_id, page] ->
              {gallery_id, String.to_integer(page) - 1}
          end

        task = Task.async(fn -> reply(message, gallery_id, page, blacklist) end)

        # Wait for a while to avoid triggering the rate limiter.
        Process.sleep(2000)

        case Task.await(task, :infinity) do
          {:ok, response} ->
            {:ok, response}

          _error ->
            {:error, "Failed to create preview for #{Constants.gallery_url(gallery_id)}"}
        end
      end

    Request.register_after_send(request, fn _request ->
      unless Enum.empty?(matches) do
        errors =
          Enum.filter(matches, fn
            {:ok, _response} -> false
            {:error, _reason} -> true
          end)

        if Enum.empty?(errors) do
          Api.delete_message!(message)
        else
          Enum.each(errors, fn {:error, reason} -> Api.create_message!(message, reason) end)
        end
      end
    end)
  end
end
