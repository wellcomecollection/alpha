class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      t.text :name, null: false
      t.text :description
      t.text :references, array: true, null: false, default: []
      t.integer :records_count, null: false, default: 0
      t.integer :digitized_records_count, null: false, default: 0
    end

    add_index :types, :references
  end
end
