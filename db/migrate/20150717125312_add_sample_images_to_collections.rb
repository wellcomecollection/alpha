class AddSampleImagesToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :sample_images, :text, array: true
  end
end
