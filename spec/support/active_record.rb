require 'sqlite3'
ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

ActiveRecord::Migration.create_table :people do |t|
  t.text :person_type
end

