class AddWikipediaIntroAndImagesToPeople < ActiveRecord::Migration
  def change
    add_column :people, :wikipedia_intro, :text, array: true
    add_column :people, :wikipedia_images, :text, array: true
  end
end
