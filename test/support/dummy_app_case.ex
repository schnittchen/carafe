defmodule DummyAppCase do
  use ExUnit.CaseTemplate

  defmodule Dummy do
    defstruct [
      :name,
      :version,

      :onartsipac_path, # where a copy of this entire repo is placed for this dummy app
      :remote, # git remote / dummy repository, used by build steps
      :capistrano_wd, # working dir when executing bundler and capistrano

      :build_path, # like in the dummy's deploy config, but absolute
      :app_path # like in the dummy's deploy config, but absolute
    ]

    def new(name) do
      relative = ["dummies", name] |> Path.join

      onartsipac_path = ["/tmp/working_paths", name] |> Path.join |> Path.expand

      local = [onartsipac_path, relative] |> Path.join
      remote = local
      capistrano_wd = local

      build_path = "/home/user/build_path"
      app_path = "/home/user/app_path"

      %__MODULE__{
        name: name,
        version: "0.1.0",
        onartsipac_path: onartsipac_path,
        remote: remote,
        capistrano_wd: capistrano_wd,
        build_path: build_path,
        app_path: app_path
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
    flunk "Error: Exit status #{status}"
  end

  def assert_psuccess(result) do
    flunk "Error: #{result.err}"
  end

  def assert_pfailure(%{status: 0}) do
    flunk "Error: status code was 0"
  end

  def assert_pfailure(%{status: status} = result) when is_integer(status) do
    result
  end
end
