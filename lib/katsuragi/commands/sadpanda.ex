defmodule Katsuragi.Commands.Sadpanda do
  @moduledoc """
  Sends a stamp.
  """

  use Percussion, :command

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  alias Katsuragi.Commands.Sadpanda

  @pattern ~r"(?:exhentai|e-hentai)\S*?/g/(\w+)/(\w+)"i

  def aliases do
    ["sadpanda"]
  end

  def call(%Request{message: message} = request) do
    matches =
      for [_match, id, token] <- Regex.scan(@pattern, message.content) do
        [id, token]
      end

    for result <- Sadpanda.Api.fetch(matches) do
      with {:ok, gallery} <- result do
        embed =
          %Embed{}
          |> Embed.put_color(0x660611)
          |> Embed.put_url("https://exhentai.org/g/#{gallery.id}/#{gallery.token}/")
          |> Embed.put_image(gallery.thumbnail)
          |> Embed.put_timestamp(DateTime.to_iso8601(gallery.posted))
          |> Embed.put_title(Map.get(gallery, :title, gallery.japanese_title))
          |> Embed.put_footer("""
          Gallery with #{gallery.file_count} page(s).
          Shared by #{message.author.username}.
          """)

        embed =
          gallery.tags
          |> Map.drop(["Artist", "Group", "Parody"])
          |> Enum.reduce(embed, fn {namespace, children}, embed ->
            Embed.put_field(embed, namespace, "`#{Enum.join(children, " • ")}`", false)
          end)

        Api.create_message!(message, embed: embed)
        Process.sleep(2000)
      else
        {:error, reason} -> Api.create_message!(message, reason)
      end
    end

    Request.register_after_send(request, fn _request ->
      unless Enum.empty?(matches) do
        Api.delete_message(message)
      end
    end)
  end
end
