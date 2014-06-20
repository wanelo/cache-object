require 'spec_helper'

RSpec.describe Cache::Object::FinderMethods do
  describe "when including Cache::Object::FinderMethods" do
    let(:super_clazz) { Class.new {} }
    let(:clazz) { Class.new(super_clazz) { extend Cache::Object::FinderMethods } }

    describe "#respond_to?" do
      it "find" do
        expect(clazz).to respond_to(:find)
      end
      it "find_by_id" do
        expect(clazz).to respond_to(:find_by_id)
      end
    end

    describe "#cache_object_key_name" do
      it "creates correct name" do
        expect(clazz).to receive(:name) { "ClassName" }
        expect(clazz.cache_object_key_name(12)).to eq("ClassName-12")
      end
    end

    describe "#find" do
      describe "caching interactions" do
        it "yields to super with cache" do
          expect(clazz).to receive(:cache_object_cache_by_id).with(12).once.and_call_original
          expect(super_clazz).to receive(:find).with(12).once
          clazz.find(12)
        end
      end
    end

    describe "#find_by_id" do
      describe "caching interactions" do
        it "yields to super with cache" do
          expect(clazz).to receive(:cache_object_cache_by_id).with(13).once.and_yield.and_call_original
          expect(clazz).to receive(:primary_key) { 1 }
          expect(clazz).to receive_message_chain("where.first") { nil }
          clazz.find_by_id(13)
        end
      end
    end
  end

end
