require 'cache/object/version'
require 'cache/object/config'
require 'cache/object/active_record'
require 'cache/object/adapter'
require 'cache/object/key_generator'

module Cache
  module Object
    # Your code goes here...
    def self.configure
      yield configuration
    end

    def self.configuration
      @configuration ||= Cache::Object::Config.new
    end

    def self.adapter
      @adapter ||= configuration.adapter
    end
  end
end
