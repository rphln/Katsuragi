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
  @spec get(integer) :: {:ok, gallery} | {:error, term}
  def get(id) do
    with {:ok, response} <- download("#{Constants.base_url()}/illust/#{id}") do
      case Jason.decode!(response.body) do
        %{"error" => false, "body" => work} ->
          {:ok, work}

        _ ->
          {:error, "Unexpected response body"}
      end
    end
  end

  def download(url) do
    case Mojito.get(url, Constants.headers()) do
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
    Map.get(gallery, "uploadDate", gallery["createDate"])
  end

  @doc """
  Whether the given gallery has more than one page.
  """
  @spec multipage?(gallery) :: boolean
  def multipage?(gallery) do
    gallery["pageCount"] > 1
  end

  @doc """
  Returns a link to the Pixiv page for the given gallery.
  """
  @spec link_for(gallery) :: String.t()
  def link_for(gallery) do
    Constants.gallery_url(gallery["illustId"])
  end

  @doc """
  Returns a link to the Pixiv page for the given gallery's author.
  """
  @spec author_link_for(gallery) :: String.t()
  def author_link_for(gallery) do
    Constants.member_url(gallery["userId"])
  end
end
