require 'spec_helper'
require 'support/models'

# Only writing the features before all the units to see the semantics of
# using with actual AR finder methods
RSpec.describe "Caching" do

  before { CreateModelsForTest.migrate(:up) }
  after { CreateModelsForTest.migrate(:down) }

  let(:user) { User.create }

  it "is hot" do
    expect(user).to_not be_nil
  end

  it "Uses custom find method" do
    expect(User).to receive(:cache_object_cache_by_id).with(user.id).and_call_original
    u2 = User.find(user.id)
    expect(u2.id).to eq(user.id)
  end

it "Uses custom find_by_id method" do
    expect(User).to receive(:cache_object_cache_by_id).with(user.id).and_call_original
    u2 = User.find_by_id(user.id)
    expect(u2.id).to eq(user.id)
  end






end
