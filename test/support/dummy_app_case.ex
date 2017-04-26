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

    def kill_stray_processes(%__MODULE__{app_path: app_path} = dummy) do
      Enamel.new(as: "user", good_exits: [0, 1])
      |> Enamel.command([~w{pkill -f}, "^#{app_path |> Regex.escape}.*run_erl"])
      |> Enamel.run!

      dummy
    end

    def prepare_onartsipac_path(%__MODULE__{onartsipac_path: onartsipac_path} = dummy, from: ".") do
      File.rm_rf! dummy.onartsipac_path
      File.mkdir_p! dummy.onartsipac_path
      File.cp_r! ".", dummy.onartsipac_path
      File.rm_rf! Path.join(dummy.onartsipac_path, ".git")

      dummy
    end

    def prepare_working_directory(%__MODULE__{capistrano_wd: capistrano_wd} = dummy) do
      Enamel.command([:find, dummy.remote, ~w<-name mix.exs -exec sed -i
        s|__ONARTSIPAC_PATH__|#{dummy.onartsipac_path}| {} ;>])
      |> Enamel.command([:bundle], dir: dummy.remote)
      |> Enamel.run!

      dummy
    end

    def prepare_remote(%__MODULE__{remote: remote} = dummy) do
      Enamel.command([~w{git -C}, dummy.remote, :init])
      |> Enamel.command([~w{git -C}, dummy.remote, ~w{config user.name}, "onartsipac test user"])
      |> Enamel.command([~w{git -C}, dummy.remote, ~w{config user.email onartsipac@example.com}])
      |> Enamel.command([~w{git -C}, dummy.remote, ~w{add .}])
      |> Enamel.command([~w{git -C}, dummy.remote, ~w{commit -m bogus}])
      |> Enamel.run!

      dummy
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
