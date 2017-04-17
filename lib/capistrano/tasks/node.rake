task "node:archive:upload_and_unpack" => "local:archive_path" do
  local_archive_path = fetch(:local_archive_path)

  Rake::Task["node:archive:upload"].invoke(local_archive_path)
  Rake::Task["node:archive:unpack"].invoke(local_archive_path)
end

task "node:archive:upload", [:archive_path] => "local:archive_path" do |t, args|
  on Onartsipac::Node.hosts do |host|
    execute :mkdir, "-p", Onartsipac::Node.app_path
    upload! args[:archive_path], Onartsipac::Node.app_path.join("archive.tar.gz")
  end
end

task "node:archive:unpack"  do
  on Onartsipac::Node.hosts do |host|
    within Onartsipac::Node.app_path do
      execute :tar, "-xzvf", "archive.tar.gz"
    end
  end
end
