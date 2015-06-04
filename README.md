# Cache::Object

Cache ActiveRecord objects in memcached!

## Installation

Add this line to your application's Gemfile:

    gem 'cache-object'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cache-object

## Usage

Add a Rails initializer, for instance at `config/initializers/cache-object.rb` 

```ruby
# Use the Rails cache.
Cache::Object.configure do |c|
  c.cache = Rails.cache
end

# Use an arbitrary Dalli connection in your environment.
Cache::Object.configure do |c|
  hosts = Array(Settings.caching.memcached.hosts).clone
  hosts << {namespace: 'my.namespace',
            expires_in: 1.day,
            compress: true,
            keepalive: true,
            socket_timeout: Settings.caching.memcached.socket_timeout}

  c.cache = ActiveSupport::Cache::DalliStore.new(hosts)
end
```

Include the `Cache::Object::ActiveRecord` module into your model. When a record is saved, its attributes will be
marshalled into the cache.

```ruby
class User < ActiveRecord::Base
  include Cache::Object::ActiveRecord
end
```

By default the record is cached by the primary id. If another key should be used, `object_cache_on` can be used:

```ruby
class User < ActiveRecord::Base
  include Cache::Object::ActiveRecord
  object_cache_on :username
end
```

If instance variables that are not ActiveRecord attributes need to be cached, `object_cache_include` can be used:

```ruby
class User < ActiveRecord::Base
  include Cache::Object::ActiveRecord
  object_cache_include :shoe_size
  
  attr_accessor :shoe_size
end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/cache-object/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
