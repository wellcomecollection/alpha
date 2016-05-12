class AddEditorialBitsToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :editorial_title, :text
    add_column :collections, :editorial_content, :text
    add_column :collections, :editorial_updated_at, :datetime
    add_column :collections, :editorial_updated_by_id, :integer
  end
end
