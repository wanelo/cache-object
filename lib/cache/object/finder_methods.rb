module Cache
  module Object
    module FinderMethods
      def find(*args)
        cache_object_cache_by_id(args[0]) do
          # For some reason we get this super called outside of method error
          # if we do not call self.super in tests
          super(*args)
        end
      end

      def find_by_id(id)
        cache_object_cache_by_id(id) do
          where(self.primary_key => id).first
        end
      end

      def cache_object_cache_by_id(id, &block)
        yield
      end

      def cache_object_key_name(id)
        "#{self.name}-#{id}"
      end

    end
  end
end
