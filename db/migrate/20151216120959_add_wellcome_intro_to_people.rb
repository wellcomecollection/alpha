class AddWellcomeIntroToPeople < ActiveRecord::Migration
  def change
    add_column :people, :wellcome_intro, :text
    add_column :people, :wellcome_intro_updated_at, :datetime
    add_column :people, :wellcome_intro_updated_by_id, :integer
  end
end
