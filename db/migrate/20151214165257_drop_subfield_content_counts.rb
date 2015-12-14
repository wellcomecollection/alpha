class DropSubfieldContentCounts < ActiveRecord::Migration
  def change

    remove_index "subfield_content_counts", column: ["field_id", "subfield"]

    drop_table "subfield_content_counts" do |t|
      t.integer "field_id",        null: false
      t.string  "subfield",        null: false
      t.string  "content",         null: false
      t.integer "count",           null: false
      t.integer "digitized_count"
    end

  end
end
