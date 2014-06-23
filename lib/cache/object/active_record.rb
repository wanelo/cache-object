require 'cache/object/instance_decorator'

module Cache
  module Object
    module ActiveRecord
      def self.included(base)
        base.instance_eval do
          extend ClassMethods

          def _object_cache_attr_mappings
            @_object_cache_attr_mappings ||= []
          end

          after_destroy :expire_cache!
          after_save :write_cache!
          after_rollback :expire_cache!
        end
      end

      def write_cache!
        Cache::Object.adapter.write(_cache_object_decorator)
      end

      def expire_cache!
        Cache::Object.adapter.delete(_cache_object_decorator)
      end

      def _cache_object_decorator
        Cache::Object::InstanceDecorator.new(self, self.class._object_cache_attr_mappings)
      end

      module ClassMethods
        def find(*args)
          Cache::Object.adapter.fetch(self, *args[0]) do
            super(*args)
          end
        end

        def find_by_id(id)
          Cache::Object.adapter.fetch(self, id) do
            where(self.primary_key => id).first
          end
        end

        def object_cache_on(*attrs)
          self._object_cache_attr_mappings << attrs
          define_singleton_method("find_by_#{attrs.join('_and_')}") do |*args|
            attributes = Hash[attrs.zip(args)]
            Cache::Object.adapter.fetch_mapping(self, attributes) do
              super(*args)
            end
          end
        end
      end
    end
  end
end
