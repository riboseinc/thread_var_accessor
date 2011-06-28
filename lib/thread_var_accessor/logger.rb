# (c) 2018 Ribose Inc.
#
#

module ThreadVarAccessor
  class Logger
    @@logger = nil

    def self.initialize_logger(filepath=nil)
      return if @@logger

      begin
        require 'active_record'
        require 'logger'

        unless ActiveRecord::Base.logger
          if filepath.nil?
            filepath = File.expand_path "../../../spec/debug.log", __FILE__
          end
          puts 'made a new logger'
          ActiveRecord::Base.logger = Logger.new(filepath)
        end
        @@logger = ActiveRecord::Base.logger

      rescue LoadError
        puts "ActiveRecord::Base.logger unable to initialize"
      end

    end

    def self.error(message)
      self.initialize_logger

      begin
        @@logger.error {message}
      rescue
        puts message
      end
    end

  end
end
