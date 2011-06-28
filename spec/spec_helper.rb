# (c) 2018 Ribose Inc.
#
#

require 'thread_var_accessor'

# initialize logger
ThreadVarAccessor::Logger.initialize_logger(
  File.expand_path("../debug.log", __FILE__)
)
