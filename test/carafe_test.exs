defmodule CarafeTest do
  use ExUnit.Case

  @tag :skip
  test "versions match" do
    hex_version = Mix.Project.config |> Keyword.fetch!(:version)
    assert ~s{"#{hex_version}"} in (File.read!("lib/carafe/version.rb") |> String.split)
  end
end
