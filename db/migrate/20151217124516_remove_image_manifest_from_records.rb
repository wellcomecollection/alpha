class RemoveImageManifestFromRecords < ActiveRecord::Migration
  def change

    remove_index :records, column: ['image_manifest'], using: :gin

    remove_column :records, :image_manifest, :jsonb
  end
end
