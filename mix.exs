defmodule AutomaticAuctions.Mixfile do
  use Mix.Project

  def project do
    [app: :automatic_auctions,
     version: "0.0.1",
     elixir: "~> 1.10",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion, :cowboy, :plug, :poison],
     mod: {AutomaticAuctions, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:httpotion, "~> 3.0.2"},
    {:cowboy, "~> 1.0.0"},
    {:plug, "~> 1.5"},
    {:poison, "~> 3.1"},
    {:plug_cowboy, "~> 1.0"}]
  end
end
