task "buildhost:git:check_reachable" do
  on Onartsipac.build_host do |host|
    Onartsipac::Buildhost.git.check_repo_is_reachable
  end
end

desc "Creates or updates the repo cache on the build host"
task "buildhost:repo:update" => "buildhost:git:check_reachable" do
  on Onartsipac.build_host do |host|
    unless Onartsipac::Buildhost.git.repo_mirror_exists?
      Onartsipac::Buildhost.git.clone_repo
    else
      # .clone_repo respects the repo_path, .update_mirror not.
      within repo_path do
        Onartsipac::Buildhost.git.update_mirror
      end
    end
  end
end

desc "Deletes the build path on the build host"
task "buildhost:clean" do
  on Onartsipac.build_host do |host|
    execute :rm, "-rf", Onartsipac::Buildhost.build_path
  end
end

desc "Deletes everything in the build path on the build host, except deps/"
task "buildhost:clean:keepdeps" do
  on Onartsipac.build_host do |host|
    execute :mkdir, "-p", Onartsipac::Buildhost.build_path
    within Onartsipac::Buildhost.build_path do
      execute :find,  %w{\( -path './deps/*' -or -path ./deps \) -or -delete}
    end
  end
end

desc "Checks if the needed source revision is available on the build host"
task "buildhost:check_rev_available" => ["local:gather-rev", "buildhost:repo:update"] do
  on Onartsipac.build_host do |host|
    within repo_path do
      rev = fetch(:rev)
      execute :git, "cat-file -e #{rev}^{commit}"
    end
  end
end

desc "Prepare the build path on the build host for building a release"
task "buildhost:prepare_build_path" => ["buildhost:clean:keepdeps", "buildhost:check_rev_available"] do
  on Onartsipac.build_host do |host|
    rev= fetch(:rev)

    execute :sh, "-c", "git -C #{repo_path} archive #{rev} | tar xfC - #{Onartsipac::Buildhost.build_path}".shellescape
  end
end

desc "Execute `mix deps.get` on the build host"
task "buildhost:mix:deps.get" do
  on Onartsipac.build_host do |host|
    within Onartsipac::Buildhost.build_path do
      with Onartsipac::Buildhost.mix_env_with_arg do
        execute :mix, "local.hex", "--force"
        execute :mix, "local.rebar", "--force"
        execute :mix, "deps.get"
      end
    end
  end
end

desc "Execute `mix compile` on the build host"
task "buildhost:mix:compile" do
  on Onartsipac.build_host do |host|
    within Onartsipac::Buildhost.build_path do
      with Onartsipac::Buildhost.mix_env_with_arg do
        execute :mix, "compile"
      end
    end
  end
end

desc "Compile entire project at the build path on the build host"
task "buildhost:compile" => [
  "buildhost:mix:deps.get",
  "buildhost:mix:compile"
]

desc "Execute `mix release` on the build host"
task "buildhost:mix:release" do
  on Onartsipac.build_host do |host|
    within Onartsipac::Buildhost.build_path do
      with Onartsipac::Buildhost.mix_env_with_arg do
        execute :mix, "release", "--env=#{Onartsipac.distillery_environment}"
      end
    end
  end
end

desc "Generate release on the build host"
task "buildhost:generate_release" => [
  "buildhost:prepare_build_path",
  "buildhost:compile",
  "buildhost:mix:release"
]

task "buildhost:gather-vsn" do
  on Onartsipac.build_host do |host|
    within Onartsipac::Buildhost.build_path do
      with Onartsipac::Buildhost.mix_env_with_arg do
        arg =
          "Mix.Project.config[:version] |> IO.puts".shellescape # why, o-why?

        vsn = capture(:mix, "run", "-e", arg).chomp
        raise ArgumentError if vsn.empty?

        set :vsn, vsn
      end
    end
  end
end

task "buildhost:archive_path" => "buildhost:gather-vsn" do
  vsn = fetch(:vsn)

  archive_path =
    Onartsipac::Buildhost.build_path.join(
      "rel", Onartsipac.distillery_release,
      "releases", vsn, "#{Onartsipac.distillery_release}.tar.gz")

  set :buildhost_archive_path, archive_path
end

task "buildhost:archive:download" => ["buildhost:archive_path", "local:archive_path"] do
  buildhost_archive_path = fetch(:buildhost_archive_path)
  local_archive_path = fetch(:local_archive_path)

  on Onartsipac.build_host do |host|
    download! buildhost_archive_path, local_archive_path
  end
end
