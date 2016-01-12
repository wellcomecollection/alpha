class AddCreatorsCountToRecords < ActiveRecord::Migration
  def change
    add_column :records, :creators_count, :integer, null: false, default: 0
  end
end
