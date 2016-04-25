class AddDigCodeToCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :code, :text
    add_column :collections, :dig_code, :text
    add_index :collections, :dig_code, unique: true
  end
end
