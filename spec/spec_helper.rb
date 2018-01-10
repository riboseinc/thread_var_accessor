# (c) 2018 Ribose Inc.
#
#

require "bundler"
Bundler.require :default, :development

Dir[File.expand_path "../support/**/*.rb", __FILE__].sort.each { |f| require f }

# initialize logger
ThreadVarAccessor::Logger.initialize_logger(
  File.expand_path("../debug.log", __FILE__),
)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
end
