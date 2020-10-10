defmodule Katsuragi.Commands.Stamp do
  @moduledoc """
  Sends a stamp.
  """

  use Percussion, :command

  @stamps Enum.into(Path.wildcard("res/stamps/**/*"), %{}, fn path ->
            name =
              path
              |> Path.rootname()
              |> Path.basename()

            {name, path}
          end)

  def aliases do
    Map.keys(@stamps)
  end

  def call(%Request{invoked_with: name} = request) do
    Request.assign(request, file: @stamps[name])
  end
end
