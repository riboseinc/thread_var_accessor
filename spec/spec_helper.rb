# (c) 2018 Ribose Inc.
#
#

require "bundler"
Bundler.require :default, :development

# initialize logger
ThreadVarAccessor::Logger.initialize_logger(
  File.expand_path("../debug.log", __FILE__)
)
