module Cache
  module Object
    class Config
      attr_accessor :cache,:enabled, :ttl

      def initialize
        self.enabled = true
        self.ttl = 86400
      end
    end
  end
end
