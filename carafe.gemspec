# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carafe/version'

Gem::Specification.new do |spec|
  spec.name          = "carafe"
  spec.version       = Carafe::VERSION
  spec.authors       = ["Thomas Stratmann"]
  spec.email         = ["thomas.stratmann@9elements.com"]

  spec.summary       = %q{Deployment for Elixir applications, using capistrano}
  spec.description   = %q{Deployment for Elixir applications, using capistrano}
  spec.homepage      = "https://github.com/schnittchen/carafe"

  spec.files         = Dir.glob("{bin,lib}/**/*.rb") +
                       Dir.glob("{bin,lib}/**/*.rake") +
                       %w(README.md LICENSE.md carafe.gemspec)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
