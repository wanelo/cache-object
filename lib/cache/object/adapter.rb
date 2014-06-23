module Cache
  module Object
    class Adapter
      attr_reader :store

      def initialize(store)
        raise "Cache Store is nil" unless store
        @store = store
      end

      def write(decorator)
        decorator.keys.each do |key|
          store.write(key, decorator.instance, expires_in: ttl)
        end
      end

      def delete(decorator)
        decorator.keys.each do |key|
          store.delete(key)
        end
      end

      def fetch(klass, id, &block)
        store.fetch(KeyGenerator.key_for_object(klass.name, id),
                    expires_in: ttl,
                    &block)
      end

      def fetch_mapping(klass, attributes, &block)
        store.fetch(KeyGenerator.key_for_mapping(klass.name, attributes),
                    expires_in: ttl,
                    &block)
      end

      private

      def ttl
        Cache::Object.configuration.ttl
      end
    end
  end
end
