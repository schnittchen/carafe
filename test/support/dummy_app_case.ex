defmodule DummyAppCase do
  use ExUnit.CaseTemplate

  defmodule Dummy do
    defstruct [
      :name,
      :source,
      :poptions,
      :remote
    ]

    def new(name) do
      source = ["dummies", name] |> Path.join
      %__MODULE__{
        name: name,
        source: source,
        poptions: [dir: source],
        remote: ["/tmp", "repo_#{name}"] |> Path.join
      }
    end
  end

  using do
    quote do
      import DummyAppCase

      setup do
        "" <> name = @dummy_name
        dummy = Dummy.new(name)

        {:ok, %{dummy: dummy}}
      end
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
end
