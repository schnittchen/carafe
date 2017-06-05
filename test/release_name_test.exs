defmodule ReleaseNameTest do
  @dummy_name "dummy1"
  use DummyAppCase, async: false

  setup %{dummy: dummy} do
    distillery_release = "custom_release"

    # Configure :distillery_release variable in config/deploy.rb
    File.write(
      [dummy.capistrano_wd, "config/deploy.rb"] |> Path.join,
      ~s{set :distillery_release, "#{distillery_release}"},
      [:append])

    {:ok, %{dummy: %{ dummy | distillery_release: distillery_release }}}
  end

  test "mix release creates a tarball at the expected path", %{dummy: dummy} do
    Enamel.new(dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:prepare_build_path})
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:compile})
    |> Enamel.run!

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:mix:release})
    |> Enamel.run!

    release_version = dummy.version

    artifact_path = [
      dummy.build_path,
      "_build/#{dummy.distillery_env}",
      "rel/#{dummy.distillery_release}/releases/#{release_version}/#{dummy.distillery_release}.tar.gz"
    ] |> Path.join

    assert File.exists?(artifact_path)
  end

  test "full deploy of a release", %{dummy: dummy} do
    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production node:ping}, expect_fail: true)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:generate_release buildhost:archive:download node:archive:upload_and_unpack node:full_restart})
    |> Enamel.command(~w{bundle exec cap --trace production node:ping})
    |> Enamel.run!
  end

  def flunk_for_reason(reason, command) do
    flunk "Command #{command} failed with reason: #{reason}"
  end
end

