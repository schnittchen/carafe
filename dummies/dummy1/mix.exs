defmodule Dummy1.Mixfile do
  use Mix.Project

  def project do
    [app: :dummy1,
     version: "0.1.0",
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
    [extra_applications: [:logger, :edeliver]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:edeliver, "~> 1.4.2"},
      {:distillery, "~> 0.9"}, # even though onartsipac already depends on distillery,
        # edeliver complains it cannot detect it.
      {:onartsipac, path: "__ONARTSIPAC_PATH__"} # the path will be replaced in CI
    ]
  end
end