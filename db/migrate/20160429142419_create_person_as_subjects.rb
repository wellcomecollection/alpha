class CreatePersonAsSubjects < ActiveRecord::Migration
  def change
    create_table :people_as_subjects do |t|
      t.integer :record_id
      t.integer :person_id
      t.string :as, null: false
    end

    add_column :people, :records_as_subject_count, :integer, null: false, default: 0
    add_column :records, :people_as_subjects_count, :integer, null: false, default: 0

    add_index :people_as_subjects, [:record_id, :person_id], unique: true
    add_index :people_as_subjects, :person_id

  end
end
