defmodule Katsuragi.Commands.Pixiv.Authenticator do
  @moduledoc """
  Handles authentication requests, responses and expiration.
  """

  alias Katsuragi.Commands.Pixiv.Tokens
  alias Katsuragi.Commands.Pixiv.Constants

  @doc """
  Authenticates the user using a valid `username` and `password`.
  """
  @spec login(String.t(), String.t()) :: {:ok, Tokens.t()} | {:error, String.t()}
  def login(username, password) do
    authenticate(%{
      grant_type: "password",
      username: username,
      password: password
    })
  end

  @doc """
  Authenticates the user using a valid `username` and `password`.
  """
  @spec login!(String.t(), String.t()) :: Tokens.t()
  def login!(username, password) do
    {:ok, tokens} = login(username, password)
    tokens
  end

  @doc """
  Attempts to refresh the `t:Katsuragi.Commands.Pixiv.Tokens.t/0` access token using the
  refresh token.
  """
  @spec refresh(Tokens.t()) :: {:ok, Tokens.t()} | {:error, String.t()}
  def refresh(%Tokens{refresh_token: token}) do
    authenticate(%{
      grant_type: "refresh_token",
      refresh_token: token
    })
  end

  @doc """
  Attempts to refresh the `t:Katsuragi.Commands.Pixiv.Tokens.t/0` access token using the
  refresh token.
  """
  @spec refresh!(Tokens.t()) :: Tokens.t()
  def refresh!(tokens) do
    {:ok, tokens} = refresh(tokens)
    tokens
  end

  defp authenticate(form) do
    form =
      form
      |> Map.merge(%{
        client_id: Constants.client_id(),
        client_secret: Constants.client_secret(),
        get_secure_url: 1
      })
      |> URI.encode_query()

    # TODO: Replace with `strftime`.
    time = now()

    hash = :crypto.hash(:md5, [time, Constants.hash_secret()])
    hash = Base.encode16(hash, case: :lower)

    headers = [
      {"User-Agent", Constants.user_agent()},
      {"X-Client-Hash", hash},
      {"X-Client-Time", time},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    with {:ok, %{status_code: 200, body: body}} <-
           Mojito.post(Constants.auth_url(), headers, form) do
      %{"response" => response} = Jason.decode!(body)

      token =
        Tokens.new(
          response["access_token"],
          response["refresh_token"],
          response["expires_in"]
        )

      {:ok, token}
    else
      {:ok, %{status_code: 400}} ->
        {:error, "Authentication failed"}

      _ ->
        {:error, "Unknown error"}
    end
  end

  defp now do
    time = NaiveDateTime.utc_now()

    [year, month, day, hour, minute, second] =
      [time.year, time.month, time.day, time.hour, time.minute, time.second]
      |> Enum.map(&to_string/1)
      |> Enum.map(&String.pad_leading(&1, 2, "0"))

    "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}+00:00"
  end
end
