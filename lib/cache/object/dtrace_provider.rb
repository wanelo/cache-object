begin
  require 'usdt'
rescue LoadError => err
  puts "UDST Gem not found. In order to enable dtrace include usdt gem"
end

module Cache
  module Object
    class DTraceProvider
      attr_reader :provider, :probes

      def initialize
        return unless defined?(USDT::Provider)
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
          delete: provider.probe(:adapter, :delete, :string, :string)
        }
      end

      def self.provider
        @provider ||= new.tap do |p|
          p.provider.enable
        end
      end

      def self.fire!(probe_name, *args)
        return unless defined?(USDT::Provider)
        raise "Unknown probe: #{probe_name}" unless self.provider.probes[probe_name]
        probe = self.provider.probes[probe_name]
        probe.fire(*args) if probe.enabled?
      end
    end
  end
end

