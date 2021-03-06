task "node:archive:upload_and_unpack" => "local:archive_path" do
  local_archive_path = fetch(:local_archive_path)

  Rake::Task["node:archive:upload"].invoke(local_archive_path)
  Rake::Task["node:archive:unpack"].invoke
end

task "node:archive:upload", [:archive_path] => "local:archive_path" do |t, args|
  on app_hosts do |host|
    execute :mkdir, "-p", app_path
    upload! args[:archive_path], app_path.join("archive.tar.gz")
  end
end

task "node:archive:unpack"  do
  on app_hosts do |host|
    within app_path do
      execute :tar, "-xzvf", "archive.tar.gz"
    end
  end
end

#task "node:archive:unlink"  do
#  on app_hosts do |host|
#    within app_path do
#      execute :rm, archive_path
#    end
#  end
#end


desc "Pings the node on each server, fails if one is not responding"
task "node:ping" do
  # TODO in case of failure, we should collect all failing nodes
  # and report eventually.
  script = fetch(:distillery_release)
  on app_hosts do |host|
    within app_path do
      execute "bin/#{script}", "ping"
      info "Host #{host}: pong"
    end
  end
end

desc "Starts all nodes. Has no effect on servers where a node is already running"
task "node:start" do
  script = fetch(:distillery_release)
  on app_hosts do |host|
    within app_path do
      execute "bin/#{script}", "start"
    end
  end
end

desc "Stops all nodes."
task "node:stop" do
  # FIXME we should attempt to stop all nodes before potentially failing
  script = fetch(:distillery_release)
  on app_hosts do |host|
    within app_path do
      execute "bin/#{script}", "stop"
    end
  end
end

task "node:stop-if-running" do
  script = fetch(:distillery_release)
  on app_hosts do |host|
    within app_path do
      if test("bin/#{script}", "ping")
        execute "bin/#{script}", "stop"
      end
    end
  end
end

desc "Restarts the node, making sure a new version (including ERTS) is booted."
task "node:full_restart" => ["node:stop-if-running", "node:start"] do
  script = fetch(:distillery_release)
  app = fetch(:application) { raise ":application has not been set" }

  on app_hosts do |host|
    within app_path do
      # Don't know why the additional `cd` is needed here.
      execute <<-EOS
        cd #{app_path}; for i in {1..10}; do bin/#{script} ping && break || true; sleep 1; done
      EOS

      elixir = %{
        fn -> Application.started_applications |> Enum.any?(fn info -> elem(info, 0) == :#{app} end) end
        |> Stream.repeatedly
        |> Stream.each(fn running -> unless running, do: :timer.sleep(250) end)
        |> Enum.any?
      }
      execute_elixir elixir
    end
  end
end

desc "Attach to a running node, for introspection"
task "node:attach" do
  script = fetch(:distillery_release)
  on app_hosts do |host|

    puts "Attaching to node. When you are done, make sure to detach with Ctrl-D (otherwise node goes down)"

    # This does not respect the configured host's ssh_options,
    # and depends on the ssh binary of the local host.

    args =
      [
        "-l#{host.user}",
        "-t",
        ("-p#{host.port}" if host.port),
        host.hostname,
        "sh -c 'cd #{app_path} && bin/#{script} attach'"
      ].compact

    pid = spawn("ssh", *args)
    Process.waitpid(pid, Process::WUNTRACED)
    raise "Error, node probably not running" unless $?.success?
  end
end

