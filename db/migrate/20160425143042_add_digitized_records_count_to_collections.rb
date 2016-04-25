class AddDigitizedRecordsCountToCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :digitized_records
    add_column :collections, :digitized_records_count, :integer, null: false, default: 0
  end
end
