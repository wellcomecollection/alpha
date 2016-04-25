class CreateRecordTypes < ActiveRecord::Migration
  def change
    create_table :record_types do |t|
      t.integer :record_id, null: false
      t.integer :type_id, null: false
    end

    add_index :record_types, [:record_id, :type_id], unique: true
  end
end
