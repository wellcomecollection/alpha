class DropIndexesOnJsonColumnsForRecords < ActiveRecord::Migration
  def change
    remove_index :records, column: [:package], using: :gin
    remove_index :records, column: [:metadata], using: :gin
  end
end
