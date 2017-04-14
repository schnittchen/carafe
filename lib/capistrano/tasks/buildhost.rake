task "buildhost:git:check_reachable" do
  Onartsipac.on_build_host do |host|
    Onartsipac::Buildhost.git.check_repo_is_reachable
  end
end

desc "Creates or updates the repo cache on the build host"
task "buildhost:repo:update" => "buildhost:git:check_reachable" do
  Onartsipac.on_build_host do |host|
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
  Onartsipac.on_build_host do |host|
    execute :rm, "-rf", Onartsipac::Buildhost.build_path
  end
end

