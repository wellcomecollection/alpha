class AddHighlightedToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :highlighted, :boolean, null: false, default: false

    add_index :subjects, :highlighted, where: "(highlighted is true)"
  end
end
