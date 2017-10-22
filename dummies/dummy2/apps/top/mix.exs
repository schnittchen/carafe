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

  def application do
    [mod: {Top, []},
     extra_applications: [:logger]]
  end

  defp deps do
    [
      {:carafe, path: "__HEX_PACKAGE_PATH__"}, # the path will be replaced in CI
      {:other, in_umbrella: true}
    ]
  end
end
