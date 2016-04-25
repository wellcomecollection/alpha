class Collection < ActiveRecord::Base; end

class AddSlugToCollections < ActiveRecord::Migration
  def up
    add_column :collections, :slug, :text, null: false, default: ''

    Collection.find_each do |collection|
      collection.update_attribute(:slug, collection.dig_code.gsub('dig',''))
    end

    change_column_default :collections, :slug, nil
    add_index :collections, :slug, unique: true

  end

  def down
    remove_index :collections, :slug
    remove_column :collections, :slug
  end
end
