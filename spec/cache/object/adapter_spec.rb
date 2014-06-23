require 'spec_helper'

RSpec.describe Cache::Object::Adapter do

  before do
    allow(Cache::Object.configuration).to receive(:ttl).and_return(118)
  end

  let(:cache_store) { double("CacheStore", write: true) }
  let(:adapter) { Cache::Object::Adapter.new(cache_store) }
  let(:instance) { double(class: double(name: "User")) }

  describe "#delete" do
    it "dispatches to delete" do
      expect(cache_store).to receive(:delete).with("User-1")
      expect(cache_store).to receive(:delete).with("User-1-blah")

      adapter.delete(double(instance: instance, keys: ["User-1", "User-1-blah"]))
    end
  end

  describe "#write" do
    it "dispatches to write" do
      expect(cache_store).to receive(:write).with("User-1", instance, expires_in: 118)
      expect(cache_store).to receive(:write).with("User-1-blah", instance, expires_in: 118)

      adapter.write(double(instance: instance, keys: ["User-1", "User-1-blah"]))
    end
  end

  describe "#fetch" do
    it "fetches the object from the cache_store" do
      expect(cache_store).to receive(:fetch).with("User-1", expires_in: 118).and_yield
      expect { |b|
        adapter.fetch(instance.class, 1, &b)
      }.to yield_control
    end
  end

  describe "#fetch_mapping" do
    it "fetches the object from the cache store based on the attributes" do
      expect(cache_store).to receive(:fetch).with("User-user_id-1-name-bob", expires_in: 118).and_yield
      expect { |b|
        adapter.fetch_mapping(instance.class, { user_id: 1, name: "bob" }, &b)
      }.to yield_control
    end
  end
end
