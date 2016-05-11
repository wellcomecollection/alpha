class AddHighlightedToTypes < ActiveRecord::Migration
  def change
    add_column :types, :highlighted, :boolean, null: false, default: false
  end
end
