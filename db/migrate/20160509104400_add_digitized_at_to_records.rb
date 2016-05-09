class AddDigitizedAtToRecords < ActiveRecord::Migration
  def change
    add_column :records, :digitized_at, :datetime
  end
end
