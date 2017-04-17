defmodule DummyAppCase do
  use ExUnit.CaseTemplate

  defmodule Dummy do
    defstruct [
      :name,
      :version,
      :source,
      :base,
      :local,
      :poptions,
      :remote,
      :build_path
    ]

    def new(name) do
      source = ["dummies", name] |> Path.join

      base = ["/tmp/bases", name] |> Path.join |> Path.expand
      local = [base, source] |> Path.join
      remote = local

      build_path = "/home/user/build_path"

      %__MODULE__{
        name: name,
        version: "0.1.0",
        source: source,
        base: base,
        local: local,
        poptions: [dir: remote],
        remote: remote,
        build_path: build_path
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
