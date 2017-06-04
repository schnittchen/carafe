task "local:gather-rev" do
  branch = fetch(:branch) { raise "you need to set :branch to a branch name or :current" }

  rev_param =
    if branch == :current
      "@"
    else
      branch
    end

  rev =
    run_locally do
      capture :git, "rev-parse", rev_param
    end

  set :rev, rev
  set :abbrev_rev, rev[0..9]
end

# Determines and saves the local path for an archive
task "local:archive_path" do
  # TODO
  archive_path = "archive.tar.gz"
  set :local_archive_path, archive_path
end
