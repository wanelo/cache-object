require 'cache/object'
require 'rspec/collection_matchers'
require 'rspec/its'
RSpec.configure do |config|

  config.before(:each) do
    Cache::Object.instance_variable_set(:@configuration, nil)
    Cache::Object.instance_variable_set(:@adapter, nil)
  end

  config.after(:each) do
    Cache::Object.instance_variable_set(:@configuration, nil)
    Cache::Object.instance_variable_set(:@adapter, nil)
  end

  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!

  config.filter_run_excluding(platform: 'ruby') if RUBY_PLATFORM == 'java'
end
