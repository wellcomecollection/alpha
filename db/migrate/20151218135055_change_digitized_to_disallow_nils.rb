class ChangeDigitizedToDisallowNils < ActiveRecord::Migration
  def up
    # We no longer need to distinguish between non-digitized things and
    # things whose digitization is uncertain (nil) – as we think we now
    # know about all digitized things. Maintaining the nils is confusing
    # and makes it more complex to index with elasticsearch.
    change_column :records, :digitized, :boolean, null: false, default: false
  end

  def down
    # We can't go back, as we've deliberately lost the distinction between nil
    # and false for 'digitized', and that data can't be recovered.
    #raise ActiveRecord::IrreversibleMigration
  end
end
