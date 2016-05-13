class AddRightsToRecords < ActiveRecord::Migration
  def change
    add_column :records, :rights, :text
  end
end
