class AddPackageToRecords < ActiveRecord::Migration
  def change
    add_column :records, :package, :jsonb
  end
end
