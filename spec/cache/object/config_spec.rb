require 'spec_helper'


RSpec.describe Cache::Object do

  describe ".configure" do
    let(:clazz) { Class.new }

    describe "#cache" do
      it "sets cache" do
        Cache::Object.configure { |c| c.cache = clazz }
        expect(Cache::Object.configuration.cache).to eq(clazz)
      end
    end

    describe "#enabled" do
      it "is enabled by default" do
        expect(Cache::Object.configuration.enabled).to eq(true)
      end


      it "is disabled if set false" do
        Cache::Object.configure { |c| c.enabled = false }
        expect(Cache::Object.configuration.enabled).to eq(false)
      end
    end

    describe "#ttl" do
      it "sets to time" do
        Cache::Object.configure { |c| c.ttl = 1234 }
        expect(Cache::Object.configuration.ttl).to eq(1234)
      end
      it "is one day by default" do
        expect(Cache::Object.configuration.ttl).to eq(86400)
      end

    end


  end


end
