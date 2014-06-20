require 'cache/object'
RSpec.configure do |config|

  config.before do
    Cache::Object.instance_variable_set(:@configuration, nil)
  end

  config.after do
    Cache::Object.instance_variable_set(:@configuration, nil)
  end

  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!

end
