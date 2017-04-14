defmodule OnartsipacTest do
  use ExUnit.Case
  doctest Onartsipac

  test "foo" do
    Porcelain.exec("bundle", [], dummy1_poptions())
    |> assert_psuccess
  end

  defp dummy1_poptions do
    [dir: "dummies/dummy1"]
  end

  defp assert_psuccess(%{err: nil, status: 0} = result) do
    result
  end

  defp assert_psuccess({:error, reason}) do
    flunk "Error: #{reason}"
  end

  defp assert_psuccess(%{err: nil, status: status}) do
    flunk "Error: Exit status #{status}"
  end

  defp assert_psuccess(result) do
    flunk "Error: #{result.err}"
  end
end
