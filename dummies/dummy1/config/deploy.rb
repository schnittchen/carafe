# config valid only for current version of Capistrano
lock "3.8.0"

set :application, "my_app_name"
set :repo_url, "/tmp/repo"

set :repo_path, "/home/user/dummy1_repo"
set :build_path, "build_path"
server "localhost", user: "user", roles: %w{build}
