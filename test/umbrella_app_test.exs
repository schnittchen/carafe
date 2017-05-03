defmodule UmbrellaAppTest do
  @dummy_name "dummy2"
  use DummyAppCase, async: false

  test "full deploy of a release", %{dummy: dummy} do
    Enamel.new(on_failure: &flunk_for_reason/2, dir: dummy.capistrano_wd)
    |> Enamel.command(~w{bundle exec cap --trace production buildhost:generate_release buildhost:archive:download node:archive:upload_and_unpack node:full_restart})
    |> Enamel.command(~w{bundle exec cap --trace production node:ping})
    |> Enamel.run!
  end

  def flunk_for_reason(reason, command) do
    flunk "Command #{command} failed with reason: #{reason}"
  end
end
