class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :email, null: false
      t.text :password_digest, null: false
      t.boolean :admin, null: false, default: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
