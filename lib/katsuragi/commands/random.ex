defmodule Katsuragi.Commands.Random do
  @moduledoc """
  Chooses a random number.
  """

  use Percussion, :command

  def aliases do
    ["random"]
  end

  def describe do
    @moduledoc
  end

  def usage do
    ["<max>", "<min> <max>"]
  end

  def call(%Request{arguments: arguments}) do
    case arguments do
      [max] ->
        do_handle("0", max)

      [min, max] ->
        do_handle(min, max)

      _other ->
        "Invalid arguments."
    end
  end

  defp do_handle(min, max) do
    with {min, _} <- Integer.parse(min),
         {max, _} <- Integer.parse(max) do
      "Your lucky number is `#{Enum.random(min..max)}`!"
    else
      _ -> "Arguments `min` and `max` must be integers."
    end
  end
end
