# config valid only for current version of Capistrano
lock "~> 3.8.0"

set :application, "dummy1"
set :repo_url, "__REMOTE__"

set :repo_path, "dummy1_repo"
set :build_path, "build_path"
server "localhost", user: "user", roles: %w{build}
