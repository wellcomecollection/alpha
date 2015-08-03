class AddDigitizedCountToSubfieldContentCounts < ActiveRecord::Migration
  def change
    add_column :subfield_content_counts, :digitized_count, :integer
  end
end
