defmodule Katsuragi.Commands.Sadpanda.Api do
  @moduledoc """
  Interface for requesting gallery information.
  """

  alias Katsuragi.Commands.Sadpanda.Gallery
  alias Katsuragi.Commands.Sadpanda.Constants

  @doc """
  Fetches metadata for each element of `galleries`.

  Chunking is handled automatically.
  """
  def fetch(galleries)

  def fetch(galleries) when length(galleries) > 25 do
    galleries
    |> Enum.chunk_every(25)
    |> Enum.map(&fetch/1)
    |> Enum.concat()
  end

  def fetch(galleries) do
    form = Jason.encode!(%{"method" => "gdata", "namespace" => "1", "gidlist" => galleries})

    case Mojito.post(Constants.base_url(), [{"Content-Type", "application/json"}], form) do
      {:ok, %{status_code: 200} = response} ->
        body = Jason.decode!(response.body)
        Enum.map(body["gmetadata"], &to_gallery/1)

      {:ok, %{status_code: status_code}} ->
        [{:error, "HTTP request returned status code #{status_code}"}]

      {:error, reason} ->
        [{:error, reason}]
    end
  end

  # Convert API responses to `t:Sadpanda.Gallery.t/0` or errors.
  defp to_gallery(%{"error" => reason}) do
    {:error, reason}
  end

  defp to_gallery(response) do
    gallery = %Gallery{
      # Id
      id: Map.get(response, "gid"),
      token: Map.get(response, "token"),

      # File information
      file_count: String.to_integer(response["filecount"]),
      file_size: Map.get(response, "filesize"),

      # Titles
      title: Map.get(response, "title"),
      japanese_title: Map.get(response, "title_jpn"),

      # Tags
      tags: parse_tags(response["tags"]),
      original_tags: response["tags"],

      # Metadata
      category: Map.get(response, "category"),
      posted: parse_timestamp(response["posted"]),
      rating: String.to_float(response["rating"]),
      thumbnail: Map.get(response, "thumb"),

      # Misc
      archiver_key: Map.get(response, "archiver_key"),
      expunged: Map.get(response, "expunged"),
      torrent_count: Map.get(response, "torrentcount"),
      uploader: Map.get(response, "uploader")
    }

    {:ok, gallery}
  end

  # Converts a well-formed string-formatted unix timestamp to a `t:DateTime.t/0`.
  @spec parse_timestamp(String.t()) :: DateTime.t()
  defp parse_timestamp(contents) do
    contents |> String.to_integer() |> DateTime.from_unix!()
  end

  # Parses and groups the given tags in `contents` by `t:Sadpanda.Parser.namespace/0`.
  @spec parse_tags([String.t()]) :: %{Gallery.namespace() => [String.t()]}
  defp parse_tags(contents) do
    contents
    |> Enum.map(&parse_tag/1)
    |> Enum.group_by(
      fn {namespace, _value} -> namespace end,
      fn {_namespace, value} -> value end
    )
  end

  # Convert a tag in `namespace:value` to a `t:Sadpanda.Parser.tag/0`.
  @spec parse_tag(String.t()) :: Gallery.tag()
  defp parse_tag(content) do
    case String.split(content, ":") do
      [namespace, value] -> {String.capitalize(namespace), value}
      [value] -> {"Misc", value}
    end
  end
end
