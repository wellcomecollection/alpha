class AddIdentifiersToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :identifiers, :hstore, null: false, default: {}
  end
end
