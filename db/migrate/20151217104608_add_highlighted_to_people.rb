class AddHighlightedToPeople < ActiveRecord::Migration
  def change
    add_column :people, :highlighted, :boolean, null: false, default: false

    add_index :people, :highlighted, where: "(highlighted is true)"
  end
end
