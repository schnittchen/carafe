defmodule Top.Mixfile do
  use Mix.Project

  def project do
    [app: :top,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [mod: {Top, []},
     extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:my_app, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:edeliver, "~> 1.4.2"},
      # we actually do not need to declare the distillery dep here
      # because it is already in the top level mix.exs.
      # It can become entirely obsolete when we get rid of edeliver.
      {:distillery, "~> 1.3.5"},
      {:carafe, path: "__HEX_PACKAGE_PATH__"}, # the path will be replaced in CI
      {:other, in_umbrella: true}
    ]
  end
end
