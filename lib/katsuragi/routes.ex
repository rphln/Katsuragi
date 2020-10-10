defmodule Katsuragi.Routes do
  @moduledoc """
  Routes command requests to their matching handlers.
  """

  @prefix "]"

  alias Percussion.Router
  alias Percussion.Adapter.Nostrum

  @routes Router.new([
            Katsuragi.Commands.Stamp,
            Katsuragi.Commands.Choose,
            Katsuragi.Commands.Random,
            Katsuragi.Commands.Pixiv,
            Katsuragi.Commands.Sadpanda,
            Katsuragi.Commands.Riot,
            Katsuragi.Commands.Whale
          ])

  @doc """
  Dispatches `request` to a matching handler.
  """
  @spec dispatch(Message.t()) :: Request.t()
  def dispatch(message) do
    with {:ok, request} <- Nostrum.to_request(message, @prefix),
         {:ok, response} <- Router.dispatch(@routes, request) do
      Nostrum.create_message!(response)
    end
  end
end
