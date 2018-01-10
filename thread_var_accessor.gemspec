# -*- encoding: utf-8 -*-
# (c) 2018 Ribose Inc.
#

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "thread_var_accessor/version"

Gem::Specification.new do |s|
  s.name        = "thread_var_accessor"
  s.version     = ThreadVarAccessor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ribose Inc."]
  s.email       = ["open.source@ribose.com"]
  s.homepage    = "https://github.com/riboseinc/thread_var_accessor"
  s.license     = "MIT"

  s.summary     = %q{ThreadVarAccessor allows setting of thread-wide variables with scope binding}
  s.description = %q{ThreadVarAccessor allows setting of thread-wide variables with scope binding}

  spec_file_matcher = proc { |f| f.match(%r{^(test|spec|features)/}) }
  all_files         = `git ls-files -z`.split("\x0")

  s.files         = all_files.reject(&spec_file_matcher)
  s.test_files    = all_files.select(&spec_file_matcher)
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "pry", "~> 0.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.7"
end
