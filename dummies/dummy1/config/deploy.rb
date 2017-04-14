# config valid only for current version of Capistrano
lock "3.8.0"

set :application, "my_app_name"
set :repo_url, "/tmp/repo"

server "localhost", user: "user", roles: %w{build}
