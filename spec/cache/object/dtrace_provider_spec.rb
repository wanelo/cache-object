require 'spec_helper'

RSpec.describe Cache::Object::DTraceProvider do
  describe 'initialize' do
    it 'creates a new provider' do
      expect(USDT::Provider).to receive(:create).with(:ruby, :cache_object).and_return(double(probe: true))
      Cache::Object::DTraceProvider.new
    end
  end

  describe 'probes' do
    let(:provider) { Cache::Object::DTraceProvider.new }

    describe '#fetch' do
      subject(:probe) { provider.probes[:fetch] }
      its(:function) { should eq :adapter }
      its(:name) { should eq :fetch }
      its(:arguments) { should eq [:string, :string, :string] }
    end

    describe '#fetch_miss' do
      subject(:probe) { provider.probes[:fetch_miss] }
      its(:function) { should eq :adapter }
      its(:name) { should eq :fetch_miss }
      its(:arguments) { should eq [:string, :string, :string] }
    end


    describe '#fetch_mapping' do
      subject(:probe) { provider.probes[:fetch_mapping] }
      its(:function) { should eq :adapter }
      its(:name) { should eq :fetch_mapping }
      its(:arguments) { should eq [:string, :string, :string] }
    end

    describe '#fetch_mapping_miss' do
      subject(:probe) { provider.probes[:fetch_mapping_miss] }
      its(:function) { should eq :adapter }
      its(:name) { should eq :fetch_mapping_miss }
      its(:arguments) { should eq [:string, :string, :string] }
    end


    describe '#read_multi' do
      subject(:probe) { provider.probes[:read_multi] }
      its(:function) { should eq :adapter }
      its(:name) { should eq :read_multi }
      its(:arguments) { should eq [:string, :integer, :integer] }
    end

    describe '#write' do
      subject(:probe) { provider.probes[:write] }
      its(:function) { should eq :adapter }
      its(:name) { should eq :write }
      its(:arguments) { should eq [:string, :string, :string] }
    end

    describe '#delete' do
      subject(:probe) { provider.probes[:delete] }
      its(:function) { should eq :adapter }
      its(:name) { should eq :delete }
      its(:arguments) { should eq [:string, :string, :string] }
    end
  end

  describe ".fire!" do
    it "raises if no provider" do
      expect { Cache::Object::DTraceProvider.fire!(:fake) }.to raise_error
    end

    describe "when probe is enabled" do
      it "receives event" do
        probe = double(enabled?: true)
        provider = double(probes: { boom: probe})
        allow(Cache::Object::DTraceProvider).to receive(:provider).and_return(provider)
        expect(probe).to receive(:fire).with("hai")
        Cache::Object::DTraceProvider.fire!(:boom, "hai")
      end
    end

    describe "when probe is disabled" do
      it "does not receives event" do
        probe = double(enabled?: false)
        provider = double(probes: { boom: probe})
        allow(Cache::Object::DTraceProvider).to receive(:provider).and_return(provider)
        expect(probe).to receive(:fire).never
        Cache::Object::DTraceProvider.fire!(:boom, "hai")
      end
    end
  end

  describe '::provider' do
    it 'returns a DTraceProvider' do
      provider = Cache::Object::DTraceProvider.provider
      expect(provider).to be_a(Cache::Object::DTraceProvider)
    end
  end
end

