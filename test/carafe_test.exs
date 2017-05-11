defmodule CarafeTest do
  use ExUnit.Case

  test "versions match" do
    hex_version = Mix.Project.config |> Keyword.fetch!(:version)
    assert ~s{"#{hex_version}"} in (File.read!("lib/carafe/version.rb") |> String.split)
  end
end
