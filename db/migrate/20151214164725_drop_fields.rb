class DropFields < ActiveRecord::Migration
  def change

    remove_index :fields, column: 'tag', unique: true

    drop_table :fields do |table|
      table.text :tag, null: false
      table.integer :count, null: false
      table.integer :non_electronic_count, default: 0, null: false
    end

  end
end
