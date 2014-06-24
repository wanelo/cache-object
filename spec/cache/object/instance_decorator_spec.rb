require 'spec_helper'

RSpec.describe Cache::Object::InstanceDecorator do
  let(:decorator) { Cache::Object::InstanceDecorator.new(instance, mappings) }

  describe '#keys' do
    let(:instance) { double(id: 1, user_id: 11, sex: 'male', class: double(name: 'User', primary_key: :id)) }
    let(:mappings) { [[:user_id] , [:user_id, :sex]] }

    it 'includes the keys based on the mappings' do
      expect(decorator.keys).to include 'User-user_id-11'
      expect(decorator.keys).to include 'User-user_id-11-sex-male'
    end

    it 'includes the canonical id key' do
      expect(decorator.keys).to include 'User-1'
    end
  end
end
