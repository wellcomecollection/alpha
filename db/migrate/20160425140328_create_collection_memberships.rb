class CreateCollectionMemberships < ActiveRecord::Migration
  def change
    create_table :collection_memberships do |t|
      t.integer :collection_id
      t.integer :record_id
    end

    add_index :collection_memberships, [:collection_id, :record_id], unique: true
  end
end
