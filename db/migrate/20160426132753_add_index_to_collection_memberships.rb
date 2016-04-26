class AddIndexToCollectionMemberships < ActiveRecord::Migration
  def change
    add_index :collection_memberships, :collection_id
  end
end
