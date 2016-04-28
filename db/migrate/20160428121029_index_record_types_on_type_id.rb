class IndexRecordTypesOnTypeId < ActiveRecord::Migration
  def change
    add_index :record_types, :type_id
  end
end
