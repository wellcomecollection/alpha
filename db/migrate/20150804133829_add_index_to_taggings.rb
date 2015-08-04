class AddIndexToTaggings < ActiveRecord::Migration
  def change
    add_index :taggings, [:record_id, :subject_id], unique: true
  end
end
