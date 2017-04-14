task "buildhost:git:check_reachable" do
  Onartsipac.on_build_roles do |host|
    Onartsipac::Buildhost.git.check_repo_is_reachable
  end
end

task "foo" => "buildhost:git:check_reachable" do
end

