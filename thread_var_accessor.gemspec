# -*- encoding: utf-8 -*-
# (c) 2018 Ribose Inc.
#

$:.push File.expand_path("../lib", __FILE__)
require "thread_var_accessor/version"

Gem::Specification.new do |s|
  s.name        = "thread_var_accessor"
  s.version     = ThreadVarAccessor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ribose Inc."]
  s.email       = ["open.source@ribose.com"]
  s.homepage    = ""
  s.summary     = %q{ThreadVarAccessor allows setting of thread-wide variables with scope binding}
  s.description = %q{ThreadVarAccessor allows setting of thread-wide variables with scope binding}

  # s.rubyforge_project = "thread_var_accessor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
