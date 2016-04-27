class AddTypesCountToRecords < ActiveRecord::Migration
  def change
    add_column :records, :types_count, :integer, default: 0, null: false
  end
end
