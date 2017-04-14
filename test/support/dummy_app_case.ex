defmodule DummyAppCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import DummyAppCase
    end
  end

  def assert_psuccess(%{err: nil, status: 0} = result) do
    result
  end

  def assert_psuccess({:error, reason}) do
    flunk "Error: #{reason}"
  end

  def assert_psuccess(%{err: nil, status: status} = result) do
    IO.puts result.out
    flunk "Error: Exit status #{status}"
  end

  def assert_psuccess(result) do
    flunk "Error: #{result.err}"
  end

  def dummy_app_poptions do
    [dir: dummy_app_path()]
  end

  def dummy_app_path do
    "dummies/dummy1"
  end
end
