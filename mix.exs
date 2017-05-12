defmodule Carafe.Mixfile do
  use Mix.Project

  def project do
    [app: :carafe,
     version: "0.1.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     description: "Deployment for Elixir applications, using capistrano",
     package: package(),
     docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  defp package do
    [maintainers: ["Thomas Stratmann"],
     licenses: ["MIT"],
     links: %{"Github": "https://github.com/schnittchen/carafe"},
     files: ~w(mix.exs README.md LICENSE.md lib/**/*.ex)]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:distillery, "~> 1.3.5"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:porcelain, "~> 2.0", only: [:dev, :test]}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
