class CreatePeople < ActiveRecord::Migration
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :people do |t|
      t.text :name, null: false

      t.text :all_names, array: true

      t.integer :records_count, null: false, default: 0

      t.integer :born_in
      t.integer :died_in

      t.hstore :identifiers, null: false, default: {}

      t.timestamps null: false
    end
  end
end
