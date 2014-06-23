module Cache
  module Object
    class KeyGenerator
      def self.key_for_object(class_name, id)
        "#{class_name}-#{id}"
      end

      def self.key_for_mapping(class_name, attributes)
        attributes_key = attributes.map do |k, v|
          "#{k}-#{v}"
        end.join('-')
        "#{class_name}-#{attributes_key}"
      end
    end
  end
end
