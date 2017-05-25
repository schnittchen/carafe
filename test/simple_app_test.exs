defmodule SimpleAppTest do
  @dummy_name "dummy1"
  use DummyAppCase, async: false

  @tag :skip
  test "updating the repo cache", %{dummy: dummy} do
    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:repo:update})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:repo:update})
    |> Enamel.run!
  end

  @tag :skip
  test "cleaning the build path", %{dummy: dummy} do
    Enamel.new(as: "user")
    |> Enamel.command([:touch, dummy.build_path])
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean})
    |> Enamel.run!

    assert !File.exists?(dummy.build_path)
  end

  @tag :skip
  test "cleaning the build path partially", %{dummy: dummy} do
    Enamel.new(as: "user")
    |> Enamel.command([~w{mkdir -p}, "#{dummy.build_path}/foo"])
    |> Enamel.command([~w{mkdir -p}, "#{dummy.build_path}/deps/foo"])
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean:keepdeps})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:clean:keepdeps})
    |> Enamel.run!

    assert File.exists?([dummy.build_path, "deps/foo"] |> Path.join)
    assert !File.exists?([dummy.build_path, "foo"] |> Path.join)
  end

  @tag :skip
  test "preparing the build path and compiling", %{dummy: dummy} do
    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.run!

    assert File.exists?([dummy.build_path, "_build/prod/lib/dummy1"] |> Path.join)
  end

  @tag :skip
  test "executing mix release", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.run!

    release_name = dummy.name # TODO: make this configurable

    artifact_path = [
      dummy.build_path,
      "_build/#{dummy.distillery_env}",
      "rel/#{release_name}/releases/#{dummy.version}/#{release_name}.tar.gz"
    ] |> Path.join

    assert File.exists?(artifact_path)
  end

  @tag :skip
  test "downloading a release archive", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:archive:download})
    |> Enamel.run!

    assert File.exists?(
      [dummy.capistrano_wd, "archive.tar.gz"] |> Path.join)
  end

  @tag :skip
  test "uploading and unpacking a release archive", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
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

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production node:ping}, expect_fail: true)
    |> Enamel.command(~w{bundle exec cap --trace production node:start})
    |> Enamel.command(~w{bundle exec cap --trace production node:start})
    |> Enamel.command(~w{bundle exec cap --trace production node:ping})
    |> Enamel.command(~w{bundle exec cap --trace production node:stop})
    |> Enamel.command(~w{bundle exec cap --trace production node:stop}, expect_fail: true)
    |> Enamel.command(~w{bundle exec cap --trace production node:ping}, expect_fail: true)
    |> Enamel.command(~w{echo sleeping})
    |> Enamel.command(~w{sleep 5})
    |> Enamel.command(~w{bundle exec cap --trace production node:full_restart})
    |> Enamel.command(~w{bundle exec cap --trace production node:full_restart})
    |> Enamel.run!
  end

  test "full deploy of a release", %{dummy: dummy} do
    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{echo YYYYYYYYYYY})
    |> Enamel.command(~w{ps -auxwww})
    |> Enamel.command(~w{bundle exec cap --trace production node:ping}, expect_fail: true)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:generate_release buildhost:archive:download node:archive:upload_and_unpack node:full_restart})
    |> Enamel.command(~w{bundle exec cap --trace production node:ping})
    |> Enamel.run!
  end

  def flunk_for_reason(reason, command) do
    flunk "Command #{command} failed with reason: #{reason}"
  end
end
