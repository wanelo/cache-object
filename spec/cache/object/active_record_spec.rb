require 'spec_helper'

RSpec.describe Cache::Object::ActiveRecord do

  class FakeActiveRecord
    def self.after_save(method)
      ;
    end

    def self.after_rollback(method)
      ;
    end

    def self.after_destroy(method)
      ;
    end

    def self.find(id)
    end

    def self.find_by_name_and_age(name, age)
    end
  end

  class Model < FakeActiveRecord
    include Cache::Object::ActiveRecord

    def self.primary_key
      :id
    end

    def id
      Random.rand * 100
    end

    object_cache_on :name, :age
  end

  let(:super_clazz) { FakeActiveRecord }
  let(:clazz) { Model }

  let(:adapter) do
    Class.new do
      def fetch(clazz, id)
        yield
      end

      def fetch_mapping(klass, attributes)
        yield
      end
    end
  end

  let(:adapter_instance) { adapter.new }

  before do
    allow(Cache::Object).to receive(:adapter).and_return(adapter_instance)
  end

  describe '.included' do
    it 'receives correct callbacks' do
      expect(clazz).to receive(:after_save).with(:write_cache!).once
      expect(clazz).to receive(:after_rollback).with(:expire_cache!).once
      expect(clazz).to receive(:after_destroy).with(:expire_cache!).once
      clazz.send(:include, Cache::Object::ActiveRecord)
    end
  end

  describe 'caching methods' do
    describe '#write_cache' do
      it 'calls write cache' do
        expect(adapter_instance).to receive(:write).with(an_instance_of(Cache::Object::InstanceDecorator))
        object = clazz.new
        object.write_cache!
      end
    end

    describe '#expire_cache' do
      it 'calls write cache' do
        expect(adapter_instance).to receive(:delete).with(an_instance_of(Cache::Object::InstanceDecorator))
        object = clazz.new
        object.expire_cache!
      end
    end
  end

  describe 'Finder class methods' do
    describe '#respond_to?' do
      it 'find' do
        expect(clazz).to respond_to(:find)
      end
      it 'find_by_id' do
        expect(clazz).to respond_to(:find_by_id)
      end
    end

    describe '.find' do
      describe 'caching interactions' do
        it 'yields to super with cache' do
          allow(Cache::Object).to receive(:adapter).and_return(adapter.new)
          expect(super_clazz).to receive(:find).with(12).once
          clazz.find(12)
        end
      end
    end

    describe '.find_by_id' do
      describe 'caching interactions' do
        it 'yields to super with cache' do
          expect(super_clazz).to receive(:where).with(:id => 12).once { double(first: true) }
          clazz.find_by_id(12)
        end
      end
    end

    describe '.fetch_all' do
      it 'should call through to multi_get' do
        multi_getter = double(fetch_all: true)
        expect(Cache::Object::MultiGet).to receive(:new).with(clazz) { multi_getter }
        expect(multi_getter).to receive(:fetch_all).with([1,2,4])
        clazz.fetch_all([1, 2, 4])
      end
    end

    describe 'object_cache_on' do

      it 'creates_finder_methods' do
        expect(clazz).to respond_to(:find_by_name_and_age)
      end

      it 'calls fetch_mapping on the adapter' do
        expect(adapter_instance).to receive(:fetch_mapping).with(clazz, name: 'bob', age: 13).once
        clazz.find_by_name_and_age('bob', 13)
      end

      it 'calls super' do
        expect(super_clazz).to receive(:find_by_name_and_age).with('bob', 13)
        clazz.find_by_name_and_age('bob', 13)
      end
    end
  end
end

