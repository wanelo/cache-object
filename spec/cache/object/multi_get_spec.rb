require 'spec_helper'

RSpec.describe Cache::Object::MultiGet do

  let(:fake_clazz) { double(name: 'MyObj', primary_key: :foo) }
  let(:obj_arr) { 1.upto(3).map { |i| double(class: fake_clazz, id: i) } }
  let(:multi_get) { Cache::Object::MultiGet.new(fake_clazz) }
  let(:cache_store) { double('CacheStore', write: true) }
  let(:adapter) { Cache::Object::Adapter.new(cache_store) }

  describe '#object_keys' do
    it 'maps keys correctly' do
      expect(multi_get.object_keys(1..3)).to eq(['MyObj-1', 'MyObj-2', 'MyObj-3'])
    end
  end

  describe '#cached_objects' do
    it 'fetches all the mapped keys' do
      expect(Cache::Object).to receive(:adapter) { adapter }
      expect(adapter).to receive(:read_multi).with(['MyObj-1', 'MyObj-2', 'MyObj-3']) { double(values: true) }
      multi_get.cached_objects(1..3)
    end
  end

  describe '#missed_ids' do
    let(:initial_ids) { [1, 2, 3, 4, 5, 6] }
    it 'computes missed ids' do
      expect(multi_get.missed_ids(initial_ids, obj_arr)).to eq([4, 5, 6])
    end
  end

  describe '#load_remaining' do
    it 'performs missed queries' do
      expect(fake_clazz).to receive(:where).with(:foo => [1, 2, 3]).once { [double(write_cache!: true)] }
      multi_get.load_from_db([1, 2, 3])
    end
  end

  describe '#fetch_all' do
    describe 'with all expected ids' do
      it 'never calls through to db' do
        expect(multi_get).to receive(:cached_objects).with([1, 2, 3]) {  obj_arr }
        expect(multi_get).to receive(:load_from_db).never
        multi_get.fetch_all([1, 2, 3])
      end
    end

    describe 'with a cache miss' do
      it 'calls through to db' do
        expect(multi_get).to receive(:cached_objects).with([1, 2, 3]) { [ obj_arr[0] ]}
        expect(multi_get).to receive(:load_from_db).with([2, 3]) { [obj_arr[1], obj_arr[2]] }
        expect(multi_get.fetch_all([1, 2, 3])).to have(3).items
      end
    end
  end

end
