require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

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

  include Cache::Object

  # TODO:: Implement later
  def write_cache!

  end



end
