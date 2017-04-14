require "onartsipac/version"

load File.expand_path("../capistrano/tasks/buildhost.rake", __FILE__)

module Onartsipac
  def self.on_build_host
    hosts = roles(:build)

    if hosts.none?
      raise "No build host available."
    end

    if hosts.length > 1
      raise "There can only be one build host."
    end

    on hosts do |host|
      yield host
    end
  end

  module Buildhost
    def self.git
      Capistrano::SCM::Git.new
    end
  end
end
