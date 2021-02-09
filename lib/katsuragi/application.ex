defmodule Katsuragi.Application do
  @moduledoc """
  Documentation for `Katsuragi`.
  """

  use Application

  alias Katsuragi.Consumer
  alias Katsuragi.Commands.Pixiv

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    username = Application.get_env(:katsuragi, :pixiv_username)
    password = Application.get_env(:katsuragi, :pixiv_password)

    children = [
      # {Pixiv.AuthServer, username: username, password: password},
      Katsuragi.Scheduler
    ]

    consumers =
      for id <- 1..System.schedulers_online() do
        Supervisor.child_spec(Consumer, id: {Consumer, id})
      end

    Supervisor.start_link(children ++ consumers, strategy: :one_for_one)
  end
end
