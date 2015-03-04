# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cass_schema/version'

Gem::Specification.new do |spec|
  spec.name          = "cass_schema"
  spec.version       = CassSchema::VERSION
  spec.authors       = ["Arron Norwell"]
  spec.email         = ["anorwell@gmail.com"]
  spec.summary       = %q{Manage Cassandra Schemas for multiple conceptual datastores.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'cassandra-driver'
  spec.add_dependency "activesupport"
end