# (c) 2018 Ribose Inc.
#
#

module ThreadVarAccessor
  EMPTY_BIND_VALUE = Object.new

  module ClassMethods

    def thread_var_accessor(*args)
      options = {}
      options = args.pop if args.last.kind_of? Hash
      args.each {|arg|
        define_thread_accessor arg, options
      }
    end

    def define_thread_accessor var_name, options
      var_name = var_name.to_s
      raise "Invalid thread accessor name #{var_name}" unless var_name =~ /^[a-zA-Z][a-zA-Z_0-9]*$/
      selector_name = "#{var_name}!#{self.__id__}".to_sym.inspect
      selector_stack_name = "#{var_name}!stack!#{self.__id__}".to_sym.inspect
      stack_place = "Thread.current[#{selector_stack_name}]"
      var_place = "Thread.current[#{selector_name}]"
      self.instance_eval <<-HERE
        def self.bind_#{var_name} value
          stack = #{stack_place}
          old_value = #{var_place}
          stack = [old_value, stack]
          #{stack_place} = stack
          #{var_place} = value
        end

        def self.thread_key_for_#{var_name}
          #{selector_name}
        end

        def self.unbind_#{var_name}
          stack = #{stack_place}
          value, stack = *stack
          #{stack_place} = stack
          #{var_place} = value
        end

        def self.#{var_name}
          #{var_place}
        end

        def self.#{var_name}= value
          #{var_place} = value
        end

        def self.binding_#{var_name}(value = EMPTY_BIND_VALUE)
          value = #{var_name} if value == EMPTY_BIND_VALUE
          bind_#{var_name}(value)
          begin
            yield
          ensure
            unbind_#{var_name}
          end
        end
      HERE
    end

  end
end


