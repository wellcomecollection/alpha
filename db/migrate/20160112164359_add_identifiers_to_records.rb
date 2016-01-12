class AddIdentifiersToRecords < ActiveRecord::Migration
  def change
    add_column :records, :identifiers, :hstore, null: false, default: {}
  end
end
