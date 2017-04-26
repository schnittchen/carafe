defmodule OnartsipacTest do
  @dummy_name "dummy1"
  use DummyAppCase, async: false

  setup %{dummy: dummy} do
    # Kill leftover processes
    Enamel.new(as: "user", good_exits: [0, 1])
    |> Enamel.command([~w{pkill -f}, "^#{dummy.app_path |> Regex.escape}.*run_erl"])
    |> Enamel.run!

    File.rm_rf! dummy.onartsipac_path
    File.mkdir_p! dummy.onartsipac_path
    File.cp_r! ".", dummy.onartsipac_path
    File.rm_rf! Path.join(dummy.onartsipac_path, ".git")

    Enamel.command([:find, dummy.remote, ~w<-name mix.exs -exec sed -i
      s|__ONARTSIPAC_PATH__|#{dummy.onartsipac_path}| {} ;>])
    |> Enamel.run!

    Enamel.command([~w{git -C}, dummy.remote, :init])
    |> Enamel.command([~w{git -C}, dummy.remote, ~w{config user.name}, "onartsipac test user"])
    |> Enamel.command([~w{git -C}, dummy.remote, ~w{config user.email onartsipac@example.com}])
    |> Enamel.command([~w{git -C}, dummy.remote, ~w{add .}])
    |> Enamel.command([~w{git -C}, dummy.remote, ~w{commit -m bogus}])
    |> Enamel.command([:bundle], dir: dummy.remote)
    |> Enamel.run!

    :ok
  end

  test "updating the repo cache", %{dummy: dummy} do
    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:repo:update})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:repo:update})
    |> Enamel.run!
  end

  test "cleaning the build path", %{dummy: dummy} do
    Enamel.new(as: "user")
    |> Enamel.command([:touch, dummy.build_path])
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean})
    |> Enamel.run!

    assert !File.exists?(dummy.build_path)
  end

  test "cleaning the build path partially", %{dummy: dummy} do
    Enamel.new(as: "user")
    |> Enamel.command([~w{mkdir -p}, "#{dummy.build_path}/foo"])
    |> Enamel.command([~w{mkdir -p}, "#{dummy.build_path}/deps/foo"])
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean:keepdeps})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean:keepdeps})
    |> Enamel.run!

    assert File.exists?([dummy.build_path, "deps/foo"] |> Path.join)
    assert !File.exists?([dummy.build_path, "foo"] |> Path.join)
  end

  test "preparing the build path and compiling", %{dummy: dummy} do
    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.run!

    assert File.exists?([dummy.build_path, "_build/prod/lib/dummy1"] |> Path.join)
  end

  test "executing mix release", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.run!

    distillery_env = dummy.name # TODO: make this configurable
    assert File.exists?(
      [dummy.build_path,
       "rel/#{distillery_env}/releases/#{dummy.version}/#{distillery_env}.tar.gz"] |> Path.join)
  end

  test "downloading a release archive", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:archive:download})
    |> Enamel.run!

    assert File.exists?(
      [dummy.capistrano_wd, "archive.tar.gz"] |> Path.join)
  end

  test "uploading and unpacking a release archive", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:archive:download node:archive:upload_and_unpack})
    |> Enamel.run!

    assert File.exists?(
      [dummy.app_path, "bin/#{dummy.name}"] |> Path.join)
  end

  test "basic interaction with nodes", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:archive:download node:archive:upload_and_unpack})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/1, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production node:ping}, expect_fail: true)
    |> Enamel.command(~w{bundle exec cap --trace production node:start})
    |> Enamel.command(~w{bundle exec cap --trace production node:start})
    |> Enamel.command(~w{bundle exec cap --trace production node:ping})
    |> Enamel.command(~w{bundle exec cap --trace production node:stop})
    |> Enamel.command(~w{bundle exec cap --trace production node:stop}, expect_fail: true)
    |> Enamel.command(~w{bundle exec cap --trace production node:ping}, expect_fail: true)
    |> Enamel.command(~w{bundle exec cap --trace production node:full_restart})
    |> Enamel.command(~w{bundle exec cap --trace production node:full_restart})
    |> Enamel.run!
  end

  def flunk_for_reason(reason) do
    flunk "Failed with reason: #{reason}"
  end
end
