class CreateCreators < ActiveRecord::Migration
  def change
    create_table :creators do |t|
      t.integer :record_id, null: false
      t.integer :person_id, null: false
      t.text :as

      t.timestamps null: false
    end

    add_index :creators, [:record_id, :person_id], unique: true
  end
end
