defmodule Katsuragi.MixProject do
  use Mix.Project

  def project do
    [
      app: :katsuragi,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Katsuragi.Application, []}
    ]
  end

  defp deps do
    [
      {:percussion, github: "rphln/Percussion"},
      {:nostrum, "~> 0.4"},
      {:mojito, "~> 0.7"},
      {:jason, "~> 1.2"},
      {:extwitter, "~> 0.12.0"},
      {:quantum, "~> 3.0"}
    ]
  end
end
