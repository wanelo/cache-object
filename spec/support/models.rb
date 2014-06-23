require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new($STDOUT)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

module ActiveRecord
  class QueryCounter
    cattr_accessor :query_count do
      0
    end

    IGNORED_SQL = [/^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/]

    def call(name, start, finish, message_id, values)
      # FIXME: this seems bad. we should probably have a better way to indicate
      # the query was cached
      unless 'CACHE' == values[:name]
        self.class.query_count += 1 unless IGNORED_SQL.any? { |r| values[:sql] =~ r }
      end
    end
  end
end

ActiveSupport::Notifications.subscribe('sql.active_record', ActiveRecord::QueryCounter.new)

class CreateModelsForTest < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.integer :age, :default => 12
    end
  end

  def self.down
    drop_table(:users)
  end
end

class User < ActiveRecord::Base
  include Cache::Object::ActiveRecord

  object_cache_on :name, :age

  after_save :asplode_if_name_is_asplode

  def asplode_if_name_is_asplode
    raise "WOAH" if name == "asplode"
  end
end
