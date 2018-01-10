# (c) 2018 Ribose Inc.
#

# require 'bundler'
# Bundler::GemHelper.install_tasks

begin
  # Rspec 2.0
  require "rspec/core/rake_task"

  desc "Default: run specs"
  task :default => :spec
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
    t.pattern = "spec/**/*_spec.rb"
  end

rescue LoadError
  puts "Rspec not available. Install it with: gem install rspec"
end
