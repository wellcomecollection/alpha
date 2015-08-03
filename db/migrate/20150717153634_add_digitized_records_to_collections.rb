class AddDigitizedRecordsToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :digitized_records, :integer
  end
end
