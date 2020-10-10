defmodule Katsuragi.Commands.Pixiv do
  @moduledoc """
  Sends a stamp.
  """

  use Percussion, :command

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  alias Katsuragi.Commands.Pixiv.Work
  alias Katsuragi.Commands.Pixiv.AuthServer

  @pattern ~r"pixiv\S*?/artworks/(\d+)"i

  def aliases do
    ["pixiv"]
  end

  def call(%Request{message: message} = request) do
    matches =
      for [_match, gallery_id] <- Regex.scan(@pattern, message.content) do
        tokens = AuthServer.refresh_and_get()

        with {:ok, work} <- Work.get(tokens, gallery_id),
             {:ok, file} <- Work.download(tokens, work["image_urls"]["medium"]) do
          name = Path.basename(work["image_urls"]["medium"])

          description =
            work["tags"]
            |> Enum.map(&(&1["translated_name"] || &1["name"]))
            |> Enum.join(" • ")

          embed =
            %Embed{}
            |> Embed.put_color(0x0086E0)
            |> Embed.put_title(work["title"])
            |> Embed.put_author(work["user"]["name"], Work.author_link_for(work), nil)
            |> Embed.put_image("attachment://#{name}")
            |> Embed.put_description("`#{description}`")
            |> Embed.put_footer("""
            Gallery with #{work["page_count"]} page(s).
            Shared by #{message.author.username}.
            """)
            |> Embed.put_timestamp(Work.updated_at!(work))
            |> Embed.put_url(Work.link_for(work))

          file = %{body: file.body, name: name}

          Api.create_message!(message, file: file, embed: embed)
          Process.sleep(2000)
        end
      end

    Request.register_after_send(request, fn _request ->
      unless Enum.empty?(matches) do
        Api.delete_message(message)
      end
    end)
  end
end
