class AddIndexToRecordsOnTypeCount < ActiveRecord::Migration
  def change
    add_index :records, :types_count
  end
end
