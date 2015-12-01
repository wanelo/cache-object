require 'spec_helper'

RSpec.describe Cache::Object::Adapter do

  before do
    allow(Cache::Object.configuration).to receive(:ttl).and_return(118)
  end

  let(:cache_store) { double('CacheStore', write: true) }
  let(:adapter) { Cache::Object::Adapter.new(cache_store) }
  let(:instance) { double(class: double(name: "User"), id: "1") }

  describe '#delete' do
    it 'dispatches to delete' do
      expect(cache_store).to receive(:delete).with('User-1')
      expect(cache_store).to receive(:delete).with('User-1-blah')

      adapter.delete(double(instance: instance, keys: %w(User-1 User-1-blah)))
    end

    describe 'probes' do
      before do
        allow(cache_store).to receive(:delete)
      end

      it 'fires the write probe' do
        expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:delete, 'User', '1')
        adapter.delete(double(instance: instance, keys: %w(User-1 User-1-blah)))
      end
    end
  end

  describe '#write' do
    it 'dispatches to write' do
      expect(cache_store).to receive(:write).with('User-1', instance, expires_in: 118)
      expect(cache_store).to receive(:write).with('User-1-blah', instance, expires_in: 118)

      adapter.write(double(instance: instance, keys: %w(User-1 User-1-blah)))
    end

    describe 'probes' do
      before do
        allow(cache_store).to receive(:write)
      end

      it 'fires the write probe' do
        expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:write, 'User', '1', '118')
        adapter.write(double(instance: instance, keys: %w(User-1 User-1-blah)))
      end
    end
  end

  describe '#fetch' do
    it 'fetches the object from the cache_store' do
      expect(cache_store).to receive(:fetch).with('User-1', expires_in: 118).and_yield
      expect { |b|
        adapter.fetch(instance.class, 1, &b)
      }.to yield_control
    end

    describe 'probes' do
      it 'fires the fetch probe' do
        allow(cache_store).to receive(:fetch)
        expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:fetch, 'User', '1', '118')
        adapter.fetch(instance.class, 1) {}
      end

      describe 'when fetch is a miss' do
        it 'fires the fetch and fetch_miss probes' do
          allow(cache_store).to receive(:fetch).and_yield
          expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:fetch, 'User', '1', '118')
          expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:fetch_miss, 'User', '1', '118')
          adapter.fetch(instance.class, 1) {}
        end
      end
    end
  end

  describe '#fetch_mapping' do
    it 'fetches the object from the cache store based on the attributes' do
      expect(cache_store).to receive(:fetch).with('User-user_id-1-name-bob', expires_in: 118).and_yield
      expect { |b|
        adapter.fetch_mapping(instance.class, { user_id: 1, name: 'bob' }, &b)
      }.to yield_control
    end

    describe 'probes' do
      it 'fires the fetch probe' do
        allow(cache_store).to receive(:fetch)
        expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:fetch_mapping, 'User', { user_id: 1, name: 'bob' }.inspect, '118')
        adapter.fetch_mapping(instance.class, { user_id: 1, name: 'bob' }) {}
      end

      describe 'when fetch is a miss' do
        it 'fires the fetch and fetch_miss probes' do
          allow(cache_store).to receive(:fetch).and_yield
          expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:fetch_mapping, 'User', { user_id: 1, name: 'bob' }.inspect, '118')
          expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:fetch_mapping_miss, 'User', { user_id: 1, name: 'bob' }.inspect, '118')
          adapter.fetch_mapping(instance.class, { user_id: 1, name: 'bob' }) {}
        end
      end
    end
  end

  describe '#read_multi' do
    it 'calls read_multi on the cache_store' do
      expect(cache_store).to receive(:read_multi).with('blah').and_return({})
      adapter.read_multi(['blah'])
    end

    describe 'probes' do
      it 'fires the read_multi probe' do
        expect(Cache::Object::DTraceProvider).to receive(:fire!).with(:read_multi, %w(blah blah2).inspect, 1, 1)
        allow(cache_store).to receive(:read_multi).and_return({'blah2' => 1})
        adapter.read_multi(%w(blah blah2))
      end
    end
  end
end
