class AddWellcomeIntroToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :wellcome_intro, :text
    add_column :subjects, :wellcome_intro_updated_at, :datetime
    add_column :subjects, :wellcome_intro_updated_by_id, :integer
  end
end
