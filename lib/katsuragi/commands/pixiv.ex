defmodule Katsuragi.Commands.Pixiv do
  @moduledoc """
  Sends a stamp.
  """

  use Percussion, :command

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  alias Katsuragi.Commands.Pixiv.Work
  alias Katsuragi.Commands.Pixiv.Constants

  @pattern ~r"pixiv\S*?/artworks/(\d+)"i

  def aliases do
    ["pixiv"]
  end

  def reply(message, gallery_id) do
    with {:ok, work} <- Work.get(gallery_id),
         {:ok, file} <- Work.download(work["urls"]["regular"]) do
      name = Path.basename(work["urls"]["regular"])

      description =
        work["tags"]["tags"]
        |> Enum.map(&(&1["translation"]["en"] || &1["tag"]))
        |> Enum.join(" • ")

      embed =
        %Embed{}
        |> Embed.put_color(0x0086E0)
        |> Embed.put_title(work["title"])
        |> Embed.put_author(work["userName"], Work.author_link_for(work), nil)
        |> Embed.put_image("attachment://#{name}")
        |> Embed.put_description("`#{description}`")
        |> Embed.put_footer("""
        Gallery with #{work["pageCount"]} page(s).
        Shared by #{message.author.username}.
        """)
        |> Embed.put_timestamp(Work.updated_at!(work))
        |> Embed.put_url(Work.link_for(work))

      file = %{body: file.body, name: name}

      Api.create_message(message, file: file, embed: embed)
    end
  end

  def call(%Request{message: message} = request) do
    matches =
      for [_match, gallery_id] <- Regex.scan(@pattern, message.content) do
        task = Task.async(fn -> reply(message, gallery_id) end)

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
