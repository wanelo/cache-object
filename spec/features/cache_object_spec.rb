require 'spec_helper'
require 'support/models'

# Only writing the features before all the units to see the semantics of
# using with actual AR finder methods
RSpec.describe "Caching" do

  before do
    CreateModelsForTest.migrate(:up)
    Cache::Object.configure do |c|
      c.cache = ::ActiveSupport::Cache::MemoryStore.new
    end
  end

  after do
    CreateModelsForTest.migrate(:down)
  end

  let!(:user) { User.create(age: 13, name: "Bob") }

  describe "#find" do
    it "finds the object from the cache" do
      expect {
        expect(User.find(user.id)).to eq(user)
      }.to change { ActiveRecord::QueryCounter.query_count }.by(0)
    end
  end

  describe "#find_by_id" do
    it "finds the object from the cache" do
      expect {
        expect(User.find_by_id(user.id)).to eq(user)
      }.to change { ActiveRecord::QueryCounter.query_count }.by(0)
    end
  end

  describe "#find_by_name_and_age" do
    it "finds the object from the cache" do
      expect {
        expect(User.find_by_name_and_age("Bob", 13)).to eq(user)
      }.to change { ActiveRecord::QueryCounter.query_count }.by(0)
    end

    describe "when the name is changed" do
      it "writes the updated data into the cache" do
        user.update_attributes(name: "Sally")
        expect {
          fetched_user = User.find_by_name_and_age("Sally", 13)
          expect(fetched_user.name).to eq("Sally")
        }.to change { ActiveRecord::QueryCounter.query_count }.by(0)
      end
    end
  end

  describe "when user id destroyed" do
    it "tries to run a query" do
      user.destroy
      expect {
        expect {
          User.find(user.id)
        }.to raise_error
      }.to change { ActiveRecord::QueryCounter.query_count }.by(1)
    end
  end

  describe "rolling back a transaction" do
    it "expires the cache" do
      expect {
        user.update_attributes(name: "asplode")
      }.to raise_error

      expect {
        User.find(user.id)
      }.to change { ActiveRecord::QueryCounter.query_count }.by(1)
    end
  end
end
