defmodule Katsuragi.Commands.Pixiv.Constants do
  @moduledoc """
  Constants used to access the Pixiv API.
  """

  @doc """
  Base URL for the public API.
  """
  @spec base_url() :: String.t()
  def base_url, do: "https://www.pixiv.net/ajax"

  @doc """
  Value to be used in the `User-Agent` header.
  """
  def user_agent,
    do:
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36"

  @doc """
  Value to be used in the `Accept-Language` header. Determines whether tag
  translations will be sent.
  """
  def accept_language, do: "en"

  @doc """
  Authentication token, obtained by manually logging in to Pixiv and getting the `PHPSESSID`
  cookie value.
  """
  def session_token, do: Application.fetch_env!(:katsuragi, :pixiv_session_token)

  @doc """
  Request headers required to access Pixiv.
  """
  @spec headers() :: [{String.t(), String.t()}]
  def headers do
    [
      {"Accept-Language", accept_language()},
      {"PHPSESSID", session_token()},
      {"Referer", base_url()},
      {"User-Agent", user_agent()}
    ]
  end

  @doc """
  Returns the gallery URL for `id`.
  """
  @spec gallery_url(term) :: String.t()
  def gallery_url(id) do
    "https://www.pixiv.net/en/artworks/#{id}"
  end

  @doc """
  Returns the member profile URL for `id`.
  """
  @spec member_url(term) :: String.t()
  def member_url(id) do
    "https://www.pixiv.net/member.php?id=#{id}"
  end
end
