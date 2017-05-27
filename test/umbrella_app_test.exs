defmodule UmbrellaAppTest do
  @dummy_name "dummy2"
  use DummyAppCase, async: false

  # The :top app waits for itself to be started up completely
  # and writes all started applications into this file.
  @applications_file "/tmp/started_applications"

  @tag :skip
  test "full deploy of a release", %{dummy: dummy} do
    File.rm_rf @applications_file

    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:generate_release buildhost:archive:download node:archive:upload_and_unpack node:full_restart})
    |> Enamel.command(~w{bundle exec cap --trace production node:ping})
    |> Enamel.run!

    started_applications =
      File.read!("/tmp/started_applications")
      |> String.split(" ")
      |> Enum.map(&String.to_atom/1)

    assert :top in started_applications
    assert :other in started_applications
  end

  def flunk_for_reason(reason, command) do
    flunk "Command #{command} failed with reason: #{reason}"
  end
end
