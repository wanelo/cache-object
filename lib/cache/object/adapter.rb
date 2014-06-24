module Cache
  module Object
    class Adapter
      attr_reader :store

      def initialize(store)
        raise "Cache Store is nil, please initialize" unless store
        @store = store
      end

      def write(decorator)
        DTraceProvider.fire!(:write, decorator.instance.class.name, decorator.instance.id.to_s, ttl.to_s)

        decorator.keys.each do |key|
          store.write(key, decorator.instance, expires_in: ttl)
        end
      end

      def delete(decorator)
        DTraceProvider.fire!(:delete, decorator.instance.class.name, decorator.instance.id.to_s)

        decorator.keys.each do |key|
          store.delete(key)
        end
      end

      def fetch(klass, id)
        DTraceProvider.fire!(:fetch, klass.name, id.to_s, ttl.to_s)

        store.fetch(KeyGenerator.key_for_object(klass.name, id), expires_in: ttl) do
          DTraceProvider.fire!(:fetch_miss, klass.name, id.to_s, ttl.to_s)
          yield
        end
      end

      def fetch_mapping(klass, attributes, &block)
        DTraceProvider.fire!(:fetch_mapping, klass.name, attributes.inspect, ttl.to_s)

        store.fetch(KeyGenerator.key_for_mapping(klass.name, attributes), expires_in: ttl) do
          DTraceProvider.fire!(:fetch_mapping_miss, klass.name, attributes.inspect, ttl.to_s)
          yield
        end
      end

      def read_multi(args)
        total = args.size
        result = store.read_multi(*args)
        found = result.size

        DTraceProvider.fire!(:read_multi, args.inspect, found, total - found)
        result
      end

      private

      def ttl
        Cache::Object.configuration.ttl
      end
    end
  end
end
