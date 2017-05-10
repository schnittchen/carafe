defmodule DummyAppCase do
  use ExUnit.CaseTemplate

  defmodule Dummy do
    defstruct [
      :name,
      :version,

      :hex_package_path, # where the dummy points to us as a mix dep
      :gem_path, # where the dummy points to us as a gem

      :onartsipac_path, # where a copy of this entire repo is placed for this dummy app
      :remote, # git remote / dummy repository, used by build steps
      :capistrano_wd, # working dir when executing bundler and capistrano

      :build_path, # like in the dummy's deploy config, but absolute
      :app_path, # like in the dummy's deploy config, but absolute
      :distillery_env
    ]

    def new(name) do
      build_path = "/home/user/build_path"
      app_path = "/home/user/#{name}_app_path"

      %__MODULE__{
        name: name,
        version: "0.1.0",
        build_path: build_path,
        app_path: app_path,

        distillery_env: "prod" # fixed
      }
    end

    def kill_stray_processes(%__MODULE__{app_path: app_path} = dummy) do
      Enamel.new(as: "user", good_exits: [0, 1])
      |> Enamel.command([~w{pkill -f}, "^#{app_path |> Regex.escape}.*run_erl"])
      |> Enamel.run!

      dummy
    end

    def prepare_onartsipac_path(%__MODULE__{name: name} = dummy, from: ".") do
      onartsipac_path = ["/tmp/working_paths", name] |> Path.join |> Path.expand

      File.rm_rf! onartsipac_path
      File.mkdir_p! onartsipac_path
      File.cp_r! ".", onartsipac_path
      File.rm_rf! Path.join(onartsipac_path, ".git")

      hex_package_path = [onartsipac_path, "hex_package"] |> Path.join
      File.mkdir_p! hex_package_path

      Enamel.new
      |> Enamel.command(~w{mix hex.build}, dir: onartsipac_path)
      |> Enamel.command(~w{tar xf ../onartsipac-0.1.0.tar contents.tar.gz}, dir: hex_package_path)
      |> Enamel.command(~w{tar xf contents.tar.gz}, dir: hex_package_path)
      |> Enamel.run!

      %{ dummy | onartsipac_path: onartsipac_path, hex_package_path: hex_package_path, gem_path: onartsipac_path }
    end

    def prepare_working_directory(%__MODULE__{name: name, onartsipac_path: onartsipac_path, hex_package_path: hex_package_path} = dummy) when is_binary(onartsipac_path) do
      capistrano_wd = [onartsipac_path, "dummies", name] |> Path.join

      Enamel.command([:find, capistrano_wd, ~w<-name mix.exs -exec sed -i
        s|__HEX_PACKAGE_PATH__|#{hex_package_path}| {} ;>])
      |> Enamel.command([:bundle], dir: capistrano_wd)
      |> Enamel.run!

      %{ dummy | capistrano_wd: capistrano_wd }
    end

    def prepare_remote(%__MODULE__{capistrano_wd: capistrano_wd} = dummy) when is_binary(capistrano_wd) do
      Enamel.command([~w{git -C}, dummy.capistrano_wd, :init])
      |> Enamel.command([~w{git -C}, dummy.capistrano_wd, ~w{config user.name}, "onartsipac test user"])
      |> Enamel.command([~w{git -C}, dummy.capistrano_wd, ~w{config user.email onartsipac@example.com}])
      |> Enamel.command([~w{git -C}, dummy.capistrano_wd, ~w{add .}])
      |> Enamel.command([~w{git -C}, dummy.capistrano_wd, ~w{commit -m bogus}])
      |> Enamel.run!

      %{ dummy | remote: capistrano_wd }
    end
  end

  using do
    quote do
      import DummyAppCase

      setup do
        "" <> name = @dummy_name
        dummy =
          Dummy.new(name)
          |> Dummy.kill_stray_processes
          |> Dummy.prepare_onartsipac_path(from: ".")
          |> Dummy.prepare_working_directory
          |> Dummy.prepare_remote

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
