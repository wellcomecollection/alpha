class RenameRecordsToRecordsCount < ActiveRecord::Migration
  def change
    rename_column :collections, :records, :records_count
  end
end
