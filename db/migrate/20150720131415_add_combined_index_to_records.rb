class AddCombinedIndexToRecords < ActiveRecord::Migration
  def change
    add_index :records, [:year, :digitized]
  end
end
