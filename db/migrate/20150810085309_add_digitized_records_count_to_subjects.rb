class AddDigitizedRecordsCountToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :digitized_records_count, :integer, null: false, default: 0
  end
end
