defmodule Plextube.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plextube,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Plextube, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:exvcr, "~> 0.8", runtime: false},
      {:briefly, "~> 0.3"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
    ]
  end
end
