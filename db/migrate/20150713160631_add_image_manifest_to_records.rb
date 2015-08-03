class AddImageManifestToRecords < ActiveRecord::Migration
  def change
    add_column :records, :image_manifest, :jsonb
    add_index :records, :image_manifest, using: :gin
  end
end
