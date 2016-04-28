class AddParentIdToRecords < ActiveRecord::Migration
  def change
    add_column :records, :parent_id, :integer
    add_index :records, :parent_id
  end
end
