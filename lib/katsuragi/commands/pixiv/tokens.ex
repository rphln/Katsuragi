defmodule Katsuragi.Commands.Pixiv.Tokens do
  @moduledoc """
  A struct to hold credential tokens from Pixiv.

  These consist of an access token, used to authenticate requests to the web
  API, a refresh token, used to request a new access token when it expires, as
  well the expiration timestamp itself for the token.

  Note that accessing the expiration timestamp directly is considered undefined
  behaviour; methods such as `expired?/1` or `expires_in/1` should be used
  instead.
  """

  @typedoc "An API token."
  @type token :: String.t()

  @type t :: %__MODULE__{
          access_token: token | nil,
          expires_in: integer,
          last_refresh: integer,
          refresh_token: token
        }

  defstruct [:access_token, :refresh_token, :expires_in, :last_refresh]

  @doc """
  Builds a `Katsuragi.Commands.Pixiv.Tokens.t/0` from the given arguments.
  """
  @spec new(token, token, integer) :: t
  def new(access_token, refresh_token, expires_in) do
    %__MODULE__{
      access_token: access_token,
      refresh_token: refresh_token,
      expires_in: expires_in,
      last_refresh: time()
    }
  end

  @doc """
  Builds a `Katsuragi.Commands.Pixiv.Tokens.t/0` from the given refresh token. The resulting
  credential is treated as expired by default.
  """
  @spec from_refresh_token(token) :: t
  def from_refresh_token(refresh_token) do
    %__MODULE__{
      access_token: nil,
      expires_in: 0,
      last_refresh: time(),
      refresh_token: refresh_token
    }
  end

  @doc """
  Returns how many seconds are left until the token expires.
  """
  @spec expires_in(t) :: integer
  def expires_in(%__MODULE__{expires_in: expires_in, last_refresh: last_refresh}) do
    expires_in + last_refresh - time()
  end

  @doc """
  Returns whether a `Pixiv.Tokens` struct is expired.
  """
  @spec expired?(t) :: boolean
  def expired?(%__MODULE__{expires_in: expires_in} = credentials) do
    is_nil(expires_in) or expires_in(credentials) <= 0
  end

  defp time do
    System.monotonic_time(:second)
  end
end
