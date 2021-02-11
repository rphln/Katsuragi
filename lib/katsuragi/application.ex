defmodule Katsuragi.Application do
  @moduledoc """
  Documentation for `Katsuragi`.
  """

  use Application

  alias Katsuragi.Consumer

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      Katsuragi.Scheduler
    ]

    consumers =
      for id <- 1..System.schedulers_online() do
        Supervisor.child_spec(Consumer, id: {Consumer, id})
      end

    Supervisor.start_link(children ++ consumers, strategy: :one_for_one)
  end
end
