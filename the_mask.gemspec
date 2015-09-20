# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'the_mask/version'

Gem::Specification.new do |spec|
  spec.name          = "the_mask"
  spec.version       = TheMask::VERSION
  spec.authors       = ["Saoud Khalifah"]
  spec.email         = ["saouddk@gmail.com"]

  spec.summary       = %q{Socket obfuscation for purposes of data mining/gathering.}
  spec.description   = %q{TheMask provides functionality for the purposes of data mining.}
  spec.homepage      = "http://github.com/saouddk/the_mask"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 0'

  spec.add_dependency 'mechanize', '~> 2.7'
end
