class ChangeEditorialUpdatedByToEditorialUpdatedById < ActiveRecord::Migration
  def change
    rename_column :people, :editorial_updated_by, :editorial_updated_by_id
  end
end
