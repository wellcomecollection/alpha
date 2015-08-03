class ChangeYearsToStrings < ActiveRecord::Migration
  def up
    remove_index :records, :year
    remove_column :records, :year
    add_column :records, :year, :text
    add_index :records, :year
  end

  def down
    puts "What are you, some kind of animal?"
    raise ActiveRecord::IrreversibleMigration
  end

end
