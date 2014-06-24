module Cache
  module Object
    class MultiGet
      attr_accessor :clazz

      def initialize(clazz)
        @clazz = clazz
      end

      def fetch_all(ids)
        objs = cached_objects(ids)
        remaining = missed_ids(ids, objs)
        return objs if remaining.empty?
        objs + load_remaining(remaining)
      end

      def load_remaining(ids)
        primary_key = @clazz.primary_key.to_sym
        @clazz.where(primary_key => ids).to_a.each(&:write_cache!)
      end

      def object_keys(ids)
        ids.map { |id| Cache::Object::KeyGenerator.key_for_object(@clazz.name, id) }
      end

      def cached_objects(ids)
        keys = object_keys(ids)
        Cache::Object.adapter.read_multi(keys).values
      end

      def missed_ids(ids, fetched_objects)
        ids - fetched_objects.map(&:id)
      end
    end
  end
end
