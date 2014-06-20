require 'spec_helper'

RSpec.describe Cache::Object do

  describe ".included" do

    it "receives correct callbacks" do
      clazz = Class.new
      expect(clazz).to receive(:after_create).with(:write_cache!).once
      expect(clazz).to receive(:after_rollback).with(:expire_cache!).once
      clazz.send(:include, Cache::Object)
    end
  end

end

