class AddWikipediaIntroParagraphToPeople < ActiveRecord::Migration
  def change
    add_column :people, :wikipedia_intro_paragraph, :text
  end
end
