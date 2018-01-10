# (c) 2018 Ribose Inc.
#
#

require "thread_var_accessor/class_methods"

class Object
  extend ThreadVarAccessor::ClassMethods
end
