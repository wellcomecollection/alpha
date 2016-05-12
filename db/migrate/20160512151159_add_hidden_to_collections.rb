class AddHiddenToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :hidden, :boolean, null: false, default: false
  end
end
