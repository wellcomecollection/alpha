class AddAccessConditionsToRecords < ActiveRecord::Migration
  def change
    add_column :records, :access_conditions, :text
  end
end
