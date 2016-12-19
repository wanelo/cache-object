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

          def _object_cache_include
            @_object_cache_include ||= []
          end

          after_destroy :expire_cache!
          after_save :write_cache!
          after_rollback :expire_cache!
        end
      end

      def _dump(level = 0)
        additional_attributes = {}.tap do |h|
          self.class._object_cache_include.flatten.each do |key|
            h[key.to_s] = self.send(key)
          end
        end
        Marshal.dump(attributes.merge(additional_attributes))
      end

      def load_from_cache(attributes)
        self.class._object_cache_include.flatten.each do |key|
          send("#{key}=", attributes.delete(key.to_s))
        end

        _assign_attributes_from_cache(attributes)
        @relation = nil

        _initialize_from_cache
        @new_record = false
        @column_types = self.class.column_types if self.class.respond_to?(:column_types)
        @changed_attributes = {}
        @new_record = false
      end

      def write_cache!
        return unless self.send(self.class.primary_key)
        Cache::Object.adapter.write(_cache_object_decorator)
      end

      def expire_cache!
        return unless self.send(self.class.primary_key)
        Cache::Object.adapter.delete(_cache_object_decorator)
      end

      def _cache_object_decorator
        Cache::Object::InstanceDecorator.new(self, self.class._object_cache_attr_mappings)
      end

      private

      def _initialize_from_cache
        @attributes_cache, @previously_changed, @changed_attributes = {}, {}, {}
        @association_cache = {}
        @aggregation_cache = {}
        @_start_transaction_state = {}
        @readonly = @destroyed = @marked_for_destruction = false

        init_internals if respond_to?(:init_internals)
      end

      def _assign_attributes_from_cache(attributes)
        if self.class.respond_to?(:initialize_attributes)
          @attributes = self.class.initialize_attributes(attributes)
        else
          @attributes = self.class._default_attributes.dup
          init_attributes(attributes, {})
        end
      end

      module ClassMethods
        def _load(args)
          attributes = Marshal.load(args)
          object = allocate
          object.load_from_cache(attributes)
          object
        end

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

        def fetch_all(ids)
          Cache::Object::MultiGet.new(self).fetch_all(ids)
        end

        def object_cache_include(*accessors)
          self._object_cache_include << accessors
        end

        def object_cache_on(*attrs)
          puts "=== ---"
          puts "cache_object.object_cache_on #{self.name}"
          puts attrs.inspect
          puts "==="

          ActiveSupport::Notifications.instrument('cache_object.object_cache_on', attributes: attrs)
          self._object_cache_attr_mappings << attrs


          meth_name = "find_by_#{attrs.join('_and_')}"
          puts "mappings = #{self._object_cache_attr_mappings} method_name=#{meth_name}"

          define_singleton_method(meth_name) do |*args|
            ActiveSupport::Notifications.instrument('cache_object.inside_singleton_method', payload: { method_name: meth_name, klass_name: self.name })
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
