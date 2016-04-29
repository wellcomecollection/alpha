class AddYearsToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :from_year, :integer
    add_column :collections, :to_year, :integer
  end
end
