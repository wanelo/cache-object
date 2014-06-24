module Cache
  module Object
    class Config
      attr_accessor :enabled, :ttl, :adapter, :cache

      def initialize
        self.enabled = true
        self.ttl = 86400
        self.adapter = nil
        self.cache = nil
      end

      def adapter
        @adapter ||= Cache::Object::Adapter.new(cache)
      end
    end
  end
end
