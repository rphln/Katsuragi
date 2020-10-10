defmodule Katsuragi.Commands.Pixiv.Work do
  @moduledoc """
  Endpoints for retrieving information about a gallery.
  """

  @typedoc "A Pixiv gallery."
  @type gallery :: map()

  alias Katsuragi.Commands.Pixiv.Token
  alias Katsuragi.Commands.Pixiv.Constants

  @doc """
  Fetches metadata for a single gallery.
  """
  @spec get(Token.t(), integer) :: {:ok, gallery} | {:error, term}
  def get(tokens, id) do
    url =
      "#{Constants.base_url()}/illust/detail"
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(%{"illust_id" => id}))
      |> URI.to_string()

    with {:ok, response} <- download(tokens, url) do
      case Jason.decode!(response.body) do
        %{"illust" => work} ->
          {:ok, work}

        _ ->
          {:error, "Unexpected response body"}
      end
    end
  end

  @doc """
  TODO: Write this.
  """
  def download(tokens, url) do
    case Mojito.get(url, Constants.headers(tokens)) do
      {:ok, %{status_code: 200} = response} ->
        {:ok, response}

      {:ok, %{status_code: status_code}} ->
        {:error, "HTTP request returned status code #{status_code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Naively parses and returns the updated date for a gallery.
  """
  @spec updated_at!(gallery) :: String.t()
  def updated_at!(gallery) do
    Map.get(gallery, "reuploaded_time", gallery["created_time"])
  end

  @doc """
  Whether the given gallery is animated.
  """
  @spec animated?(gallery) :: boolean
  def animated?(gallery) do
    gallery["type"] == "ugoira"
  end

  @doc """
  Whether the given gallery has more than one page.
  """
  @spec multipage?(gallery) :: boolean
  def multipage?(gallery) do
    gallery["page_count"] > 1
  end

  @doc """
  Returns a link to the Pixiv page for the given gallery.
  """
  @spec link_for(gallery) :: String.t()
  def link_for(gallery) do
    Constants.gallery_url(gallery["id"])
  end

  @doc """
  Returns a link to the Pixiv page for the given gallery's author.
  """
  @spec author_link_for(gallery) :: String.t()
  def author_link_for(gallery) do
    Constants.member_url(gallery["user"]["id"])
  end
end
