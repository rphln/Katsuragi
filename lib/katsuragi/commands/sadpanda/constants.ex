defmodule Katsuragi.Commands.Sadpanda.Constants do
  @moduledoc """
  Constants used to access the E-Hentai API.
  """

  @doc """
  Base URL for the public API.
  """
  @spec base_url() :: String.t()
  def base_url, do: "https://e-hentai.org/api.php"
end
