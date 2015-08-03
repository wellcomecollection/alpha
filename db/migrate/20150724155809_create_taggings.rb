class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :record_id, null: false
      t.integer :subject_id, null: false
      t.text :label
    end
  end
end
