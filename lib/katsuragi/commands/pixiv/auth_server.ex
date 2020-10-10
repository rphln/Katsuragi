defmodule Katsuragi.Commands.Pixiv.AuthServer do
  @moduledoc """
  Storage mechanism for upkeeping tokens.
  """

  use Agent

  alias Katsuragi.Commands.Pixiv.Tokens
  alias Katsuragi.Commands.Pixiv.Authenticator

  @doc """
  Starts a tokens server.
  """
  def start_link(options)

  def start_link(tokens) when is_list(tokens) do
    start_link(Authenticator.login!(tokens[:username], tokens[:password]))
  end

  def start_link(%Tokens{} = tokens) do
    Agent.start_link(fn -> tokens end, name: __MODULE__)
  end

  @doc """
  Gets the tokens as currently stored.

  Note that this function may return stale tokens.
  """
  @spec get() :: Tokens.t()
  def get do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Refreshes and returns the stored tokens.
  """
  def refresh_and_get do
    Agent.get_and_update(__MODULE__, fn tokens ->
      tokens =
        if Tokens.expired?(tokens) do
          Authenticator.refresh!(tokens)
        else
          tokens
        end

      {tokens, tokens}
    end)
  end
end
