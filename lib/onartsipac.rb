require "onartsipac/version"

load File.expand_path("../capistrano/tasks/git.rake", __FILE__)
load File.expand_path("../capistrano/tasks/buildhost.rake", __FILE__)

module Onartsipac
  def self.build_host
    hosts = roles(:build)

    if hosts.none?
      raise "No build host available."
    end

    if hosts.length > 1
      raise "There can only be one build host."
    end

    hosts.first
  end

  def self.rev_param
    branch = fetch(:branch) { raise "you need to set :branch to a branch name or :current" }

    if branch == :current
      "@"
    else
      branch
    end
  end

  module Buildhost
    def self.git
      Capistrano::SCM::Git.new
    end

    def self.build_path
      fetch(:build_path) { raise "no build_path configured" }
    end

    def self.mix_env_with_arg
      mix_env = fetch(:mix_env) { raise "set :mix_env in stage config!" }
      { mix_env: mix_env }
    end
  end
end
