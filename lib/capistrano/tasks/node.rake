task "node:archive:upload_and_unpack" => "local:archive_path" do
  local_archive_path = fetch(:local_archive_path)

  Rake::Task["node:archive:upload"].invoke(local_archive_path)
  Rake::Task["node:archive:unpack"].invoke
end

task "node:archive:upload", [:archive_path] => "local:archive_path" do |t, args|
  on Carafe::Node.hosts do |host|
    execute :mkdir, "-p", Carafe::Node.app_path
    upload! args[:archive_path], Carafe::Node.app_path.join("archive.tar.gz")
  end
end

task "node:archive:unpack"  do
  on Carafe::Node.hosts do |host|
    within Carafe::Node.app_path do
      execute :tar, "-xzvf", "archive.tar.gz"
    end
  end
end

#task "node:archive:unlink"  do
#  on Carafe::Node.hosts do |host|
#    within Carafe::Node.app_path do
#      execute :rm, archive_path
#    end
#  end
#end


desc "Pings the node on each server, fails if one is not responding"
task "node:ping" do
  # TODO in case of failure, we should collect all failing nodes
  # and report eventually.
  script = Carafe.distillery_release
  on Carafe::Node.hosts do |host|
    within Carafe::Node.app_path do
      execute "bin/#{script}", "ping"
      info "Host #{host}: pong"
    end
  end
end

desc "Starts all nodes. Has no effect on servers where a node is already running"
task "node:start" do
  script = Carafe.distillery_release
  on Carafe::Node.hosts do |host|
    within Carafe::Node.app_path do
      p(capture "bin/#{script}", "start")
      execute :cat, "var/log/erlang.log.1"

    end
  end
end

desc "Stops all nodes."
task "node:stop" do
  # FIXME we should attempt to stop all nodes before potentially failing
  script = Carafe.distillery_release
  on Carafe::Node.hosts do |host|
    within Carafe::Node.app_path do
      execute "bin/#{script}", "stop"
    end
  end
end

task "node:stop-if-running" do
  script = Carafe.distillery_release
  on Carafe::Node.hosts do |host|
    within Carafe::Node.app_path do
      if test("bin/#{script}", "ping")
        execute "bin/#{script}", "stop"
      end
    end
  end
end

desc "Restarts the node, making sure a new version (including ERTS) is booted."
task "node:full_restart" => ["node:stop-if-running", "node:start"] do
  script = Carafe.distillery_release
  app = Carafe::Node.app_name

  # see https://github.com/boldpoker/edeliver/blob/0582a32546edca8e6b047c956e3dd4ef74b09ac1/libexec/erlang#L856
  on Carafe::Node.hosts do |host|
    within Carafe::Node.app_path do
      ponged = false
      20.times do
        if test("bin/#{script} ping")
          ponged = true
        else
          sleep 1
        end unless ponged
      end
      raise "No ping response (tried 10 times)" unless ponged

      execute "bin/#{script}", <<-EOS
      rpcterms Elixir.Edeliver run_command '[monitor_startup_progress, \"#{app}\", verbose].' | tee /dev/fd/2 | grep -e 'Started\\|^ok'
      EOS
    end
  end
end

desc "Attach to a running node, for introspection"
task "node:attach" do
  script = Carafe.distillery_release
  on Carafe::Node.hosts do |host|

    puts "Attaching to node. When you are done, make sure to detach with Ctrl-D (otherwise node goes down)"

    # This does not respect the configured host's ssh_options,
    # and depends on the ssh binary of the local host.

    args =
      [
        "-l#{host.user}",
        "-t",
        ("-p#{host.port}" if host.port),
        host.hostname,
        "sh -c 'cd #{Carafe::Node.app_path} && bin/#{script} attach'"
      ].compact

    pid = spawn("ssh", *args)
    Process.waitpid(pid, Process::WUNTRACED)
    raise "Error, node probably not running" unless $?.success?
  end
end

