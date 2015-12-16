class AddEditorialToPeople < ActiveRecord::Migration
  def change
    add_column :people, :editorial_title, :text
    add_column :people, :editorial_content, :text
    add_column :people, :editorial_updated_at, :datetime
    add_column :people, :editorial_updated_by, :integer
  end
end
