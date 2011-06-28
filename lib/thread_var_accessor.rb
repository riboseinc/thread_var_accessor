# (c) 2018 Ribose Inc.
#
#

require 'thread_var_accessor/class_methods'
require 'thread_var_accessor/extensions/object'
require 'thread_var_accessor/logger'

module ThreadVarAccessor

  def self.included(base)
    base.extend ThreadVarAccessor::ClassMethods
  end

  #
  # Sets several (possibly thread local) attributes to given values,
  # yields and then restores old values back.
  #
  # Each triple <object, attribute name, new value> is passed in this
  # order as array. The method recieves variable number of this triples.
  #
  def self.binding_many(*triples)
    restorers = []
    begin
      triples.each do |triple|
        object, attr, value = *triple
        setter = "bind_#{attr}"

        restorer = if object.respond_to?(setter)
                     proc {object.send("unbind_#{attr}")}
                   else
                     setter = "#{attr}=".intern
                     old_value = object.send(attr)
                     proc {object.send(setter, old_value)}
                   end
        object.send(setter, value)
        restorers << restorer
      end
      yield
    ensure
      restorers.reverse_each do |proc|
        begin
          proc.call
        rescue Exception => exc
          error_message = "ignoring error raised while restoring attribute value:\n#{exc}"

          ThreadVarAccessor::Logger.error(error_message)
        end

      end
    end

  end

end
