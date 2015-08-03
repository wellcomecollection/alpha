class AddImageUrisToRecords < ActiveRecord::Migration
  def change
    add_column :records, :cover_image_uris, :text, array: true
    add_column :records, :title_page_uris, :text, array: true
  end
end
