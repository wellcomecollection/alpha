class AllowNullsInLeaderForRecords < ActiveRecord::Migration
  def change
    change_column_null :records, :leader, true
  end
end
