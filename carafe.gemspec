# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carafe/version'

Gem::Specification.new do |spec|
  spec.name          = "carafe"
  spec.version       = Carafe::VERSION
  spec.authors       = ["Thomas Stratmann"]
  spec.email         = ["thomas.stratmann@9elements.com"]

  spec.summary       = %q{Saithe9v mib4ahVe AeF9aihi eor5zuSh}
  spec.description   = %q{Saithe9v mib4ahVe AeF9aihi eor5zuSh}
  #spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # TODO include LICENSE
  spec.files         = Dir.glob("{bin,lib}/**/*.rb") +
                       Dir.glob("{bin,lib}/**/*.rake") +
                       %w(README.md carafe.gemspec)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
