class RemoveIdentifierFromSubjects < ActiveRecord::Migration
  def change
    remove_column :subjects, :identifier, :text
  end
end
