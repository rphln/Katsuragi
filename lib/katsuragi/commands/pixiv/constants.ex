defmodule Katsuragi.Commands.Pixiv.Constants do
  @moduledoc """
  Constants used to access the Pixiv API.
  """

  alias Katsuragi.Commands.Pixiv.Tokens

  @doc """
  Base URL for the public API.
  """
  @spec base_url() :: String.t()
  def base_url, do: "https://app-api.pixiv.net/v1"

  @doc """
  Endpoint for requesting and refreshing authentication tokens.
  """
  @spec auth_url() :: String.t()
  def auth_url, do: "https://oauth.secure.pixiv.net/auth/token"

  @doc """
  Public identifier used by OAuth2.
  """
  @spec client_id() :: String.t()
  def client_id, do: "MOBrBDS8blbauoSck0ZfDbtuzpyT"

  @doc """
  Private identifier used by OAuth2.
  """
  @spec client_secret() :: String.t()
  def client_secret, do: "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj"

  @doc """
  Salt used to generate the `X-Client-Hash` header.
  """
  @spec hash_secret() :: String.t()
  def hash_secret, do: "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c"

  @doc """
  Value to be used in the `User-Agent` header.
  """
  def user_agent, do: "PixivIOSApp/6.4.0"

  @doc """
  Value to be used in the `Accept-Language` header. Determines whether tag
  translations will be sent.
  """
  def accept_language, do: "en"

  @doc """
  Request headers required to access Pixiv.
  """
  @spec headers() :: [{String.t(), String.t()}]
  def headers do
    [
      {"Referer", auth_url()},
      {"User-Agent", user_agent()},
      {"Accept-Language", accept_language()}
    ]
  end

  @doc """
  Request headers required to access Pixiv with authentication.
  """
  @spec headers(Tokens.t()) :: [{String.t(), String.t()}]
  def headers(%Tokens{access_token: access_token}) do
    [{"Authorization", "Bearer #{access_token}"} | headers()]
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
