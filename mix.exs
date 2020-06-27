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
    [applications: [:logger, :httpoison, :plug_cowboy, :poison, :secure_random],
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
    [{:httpoison, "~> 1.6"},
    {:poison, "~> 3.1"},
    {:plug_cowboy, "~> 1.0"},
    {:secure_random, "~> 0.5.1"},
    {:libcluster, "~> 3.2.1"},
    {:horde, "~> 0.7.0"}]
  end
end
