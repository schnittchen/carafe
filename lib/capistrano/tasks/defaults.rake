Carafe::MissingConfig = Class.new(RuntimeError)

set :application, -> { raise Carafe::MissingConfig, "variable :application has not been configured" }
set :mix_env, -> { raise Carafe::MissingConfig, "variable :mix_env has not been configured" }

set :distillery_release, -> {
  begin
    fetch(:application)
  rescue Carafe::MissingConfig
    raise Carafe::MissingConfig, "unable to fall back to :application for variable :distillery_release, reason: #{$!}"
  end
}

set :distillery_environment, -> {
  begin
    fetch(:mix_env)
  rescue Carafe::MissingConfig
    raise Carafe::MissingConfig, "unable to fall back to :mix_env for variable :distillery_environment, reason: #{$!}"
  end
}
