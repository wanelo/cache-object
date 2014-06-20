require "cache/object/version"
require "cache/object/config"
require "cache/object/finder_methods"

module Cache
  module Object
    # Your code goes here...
    def self.configure
      yield configuration
    end

    def self.configuration
      @configuration ||= Cache::Object::Config.new
    end

    def self.included(base)
      puts "Included"
      base.send(:extend, Cache::Object::FinderMethods)

      base.instance_eval do
        after_create :write_cache!
        after_rollback :expire_cache!
      end
    end





  end
end
