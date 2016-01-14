class AddSubjectIdIndexToTaggings < ActiveRecord::Migration
  def change
    add_index :taggings, :subject_id
  end
end
