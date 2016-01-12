class AddNameIndexToPeople < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_people_on_lower_name ON people (lower(name))"
  end

  def down
    execute "DROP INDEX index_people_on_lower_name"
  end
end
