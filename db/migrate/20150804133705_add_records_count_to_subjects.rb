class AddRecordsCountToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :records_count, :integer, null: false, default: 0
  end
end
