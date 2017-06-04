require "carafe/version"

load File.expand_path("../capistrano/tasks/deploy.rake", __FILE__)
load File.expand_path("../capistrano/tasks/local.rake", __FILE__)
load File.expand_path("../capistrano/tasks/buildhost.rake", __FILE__)
load File.expand_path("../capistrano/tasks/node.rake", __FILE__)

module Carafe
  module DSL
    module_function

    def build_host
      hosts = roles(:build)

      raise "No build host available." if hosts.none?
      raise "There can only be one build host." if hosts.length > 1

      hosts.first
    end

    def build_path
      Pathname(fetch(:build_path) { raise "no :build_path configured" })
    end

    def mix_env
      fetch(:mix_env) { raise "set :mix_env in stage config!" }.to_s
    end

    def app_path
      Pathname(fetch(:app_path) { raise "set :app_path node path where the release is unpacked an run" })
    end

    def app_hosts
      hosts = roles(:app)

      raise "No hosts have been configured with role 'app'" if hosts.none?

      hosts
    end

    def distillery_environment
      fetch(:distillery_environment) { mix_env }
    end

    def distillery_release
      fetch(:application) { raise "no :application configured" }
    end
  end
end

extend Carafe::DSL
SSHKit::Backend::Abstract.include Carafe::DSL
