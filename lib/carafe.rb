require "carafe/version"

load File.expand_path("../capistrano/tasks/deploy.rake", __FILE__)
load File.expand_path("../capistrano/tasks/local.rake", __FILE__)
load File.expand_path("../capistrano/tasks/buildhost.rake", __FILE__)
load File.expand_path("../capistrano/tasks/node.rake", __FILE__)

module Carafe
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

  def self.mix_env
    fetch(:mix_env) { raise "set :mix_env in stage config!" }.to_s
  end

  def self.distillery_release
    fetch(:application) { raise }
  end

  def self.distillery_environment
    fetch(:distillery_environment) { mix_env }
  end

  module Buildhost
    def self.git
      Capistrano::SCM::Git.new
    end

    def self.build_path
      Pathname(fetch(:build_path) { raise "no build_path configured" })
    end

    def self.mix_env_with_arg
      { mix_env: Carafe.mix_env }
    end
  end

  module Node
    def self.app_path
      Pathname(fetch(:app_path) { raise "set :app_path node path where the release is unpacked an run" })
    end

    def self.app_name
      fetch(:application) { raise }
    end

    def self.hosts
      hosts = roles(:app)
      if hosts.none?
        raise "No hosts have been configured with role 'app'"
      end
      hosts
    end
  end
end
