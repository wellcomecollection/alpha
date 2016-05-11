class AddHighlightedToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :highlighted, :boolean, null: false, default: false
  end
end
