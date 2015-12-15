class AddPdfThumbnailUrlToRecords < ActiveRecord::Migration
  def change
    add_column :records, :pdf_thumbnail_url, :text
  end
end
