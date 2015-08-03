class AddSomeMoreIndexes < ActiveRecord::Migration
  def change
    add_index :records, :year
    add_index :records, :package, using: :gin
  end
end
