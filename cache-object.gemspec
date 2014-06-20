# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cache/object/version'

Gem::Specification.new do |spec|
  spec.name          = "cache-object"
  spec.version       = Cache::Object::VERSION
  spec.authors       = ["Matt Camuto"]
  spec.email         = ["dev@wanelo.com"]
  spec.summary       = %q{Object R/W Caching}
  spec.description   = %q{Object R/W Caching on top of ActiveRecord}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 3.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "sqlite3"

end
