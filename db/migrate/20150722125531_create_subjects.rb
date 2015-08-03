class CreateSubjects < ActiveRecord::Migration
  def change

    create_table :subjects do |table|
      table.text :scheme
      table.text :identifier
      table.text :label
      table.text :description

      table.text :all_labels, array: true
      table.text :related_identifiers, array: true

      table.text :tree_numbers, array: true
    end

  end
end
