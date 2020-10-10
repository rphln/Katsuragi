defmodule Katsuragi.Commands.Choose do
  @moduledoc """
  Picks an item among the specified choices.
  """

  use Percussion, :command

  def aliases do
    ["choose"]
  end

  def describe do
    @moduledoc
  end

  def usage do
    ["<item>..."]
  end

  def call(%Request{arguments: []}) do
    "Nothing to choose from!"
  end

  def call(%Request{arguments: arguments}) do
    "I choose `#{Enum.random(arguments)}` for you!"
  end
end
