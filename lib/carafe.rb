require "carafe/version"

load File.expand_path("../capistrano/tasks/defaults.rake", __FILE__)
load File.expand_path("../capistrano/tasks/deploy.rake", __FILE__)
load File.expand_path("../capistrano/tasks/local.rake", __FILE__)
load File.expand_path("../capistrano/tasks/buildhost.rake", __FILE__)
load File.expand_path("../capistrano/tasks/node.rake", __FILE__)

module Carafe
  module DSL
    # Returns the build host, to be consumed by capistrano's `on` method like this:
    # ```
    # task :my_task do
    #   on build_host do
    #     ...
    #   end
    # end
    # ```
    def build_host
      hosts = roles(:build)

      raise "No build host available." if hosts.none?
      raise "There can only be one build host." if hosts.length > 1

      hosts.first
    end

    # Returns the build path on the build host, can be used with capistrano's `within` method like this:
    # ```
    # task :my_task do
    #   on build_host do |host|
    #     within build_path do
    #       ...
    #     end
    #   end
    # end
    # ```
    def build_path
      Pathname(fetch(:build_path) { raise "no :build_path configured" })
    end

    # Returns the mix environment to be used when preparing and creating the release.
    # Can be used with capistrano's `with` method like this (Note: `with` uppercases the name):
    # ```
    # task :my_task do
    #   on build_host do |host|
    #     within build_path do
    #       with mix_env: mix_env do
    #         ...
    #       end
    #     end
    #   end
    # end
    # ```
    def mix_env
      fetch(:mix_env).to_s
    end

    # Returns the path on the target hosts where releases are extracted and loaded from.
    def app_path
      Pathname(fetch(:app_path) { raise "set :app_path node path where the release is unpacked an run" })
    end

    # Returns the target hosts, to be consumed by capistrano's `on` method like this:
    # ```
    # task :my_task do
    #   on app_hosts do
    #     ...
    #   end
    # end
    # ```
    def app_hosts
      hosts = roles(:app)

      raise "No hosts have been configured with role 'app'" if hosts.none?

      hosts
    end

    # Returns the distillery environment to use, defaulting to the result of `mix_env`.
    # The distillery environment is configured in `rel/config.exs`.
    def distillery_environment
      fetch(:distillery_environment).to_s
    end

    # Execute the given elixir code on the node, through the rpc interface.
    # Fails if the code raises an exception or returns `:error` or `{:error, _}`.
    def execute_elixir(elixir_string)
      script = fetch(:distillery_release)
      execute "bin/#{script}", "rpc", "Elixir.Carafe", "execute_elixir", elixir_string.shellescape
    end
  end
end

extend Carafe::DSL
SSHKit::Backend::Abstract.include Carafe::DSL
