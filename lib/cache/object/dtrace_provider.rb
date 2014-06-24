require 'usdt'

module Cache
  module Object
    class DTraceProvider
      attr_reader :provider, :probes

      def initialize
        @provider = USDT::Provider.create(:ruby, :cache_object)

        @probes = {
          # args: Class name, id, ttl
          fetch: provider.probe(:adapter, :fetch, :string, :string, :string),
          # args: Class name, id, ttl
          fetch_miss: provider.probe(:adapter, :fetch_miss, :string, :string, :string),
          # args: Class name, attributes.inspect, ttl
          fetch_mapping: provider.probe(:adapter, :fetch_mapping, :string, :string, :string),
          # args: Class name, attributes.inspect, ttl
          fetch_mapping_miss: provider.probe(:adapter, :fetch_mapping_miss, :string, :string, :string),
          # args: args.inspect, hits, misses
          read_multi: provider.probe(:adapter, :read_multi, :string, :integer, :integer),
          # args: class_name, id, ttl
          write: provider.probe(:adapter, :write, :string, :string, :string),
          # args: class_name, id
          delete: provider.probe(:adapter, :delete, :string, :string, :string)
        }
      end

      def self.provider
        @provider ||= new.tap do |p|
          p.provider.enable
        end
      end

      def self.fire!(probe_name, *args)
        raise "Unknown probe: #{probe_name}" unless self.provider.probes[probe_name]
        probe = self.provider.probes[probe_name]
        probe.fire(*args) if probe.enabled?
      end
    end
  end
end

