# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cheatr/version'

Gem::Specification.new do |spec|
  spec.name          = "cheatr"
  spec.version       = Cheatr::VERSION
  spec.authors       = ["Ernesto García"]
  spec.email         = ["gnapse@gmail.com"]
  spec.description   = %q{Display cheat sheets for a variety of programs, tools and libraries, right on the command line.}
  spec.summary       = %q{Display cheat sheets right on the command line.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "slop"

  # server dependencies
  spec.add_dependency "git"
  spec.add_dependency "sinatra"
  spec.add_dependency "activemodel"
  spec.add_dependency "redcarpet"

  # client dependencies
  spec.add_dependency "rest-client"
  spec.add_dependency "pager"

  # test dependencies
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
