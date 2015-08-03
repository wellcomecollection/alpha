class AddDigitizedToRecords < ActiveRecord::Migration
  def change
    add_column :records, :digitized, :boolean
    add_index :records, :digitized
  end
end
