class Subject < ActiveRecord::Base

  has_many :taggings
  has_many :records, through: :taggings

  def to_param
    "S#{id}"
  end

  def update_records_count!
    self.records_count = records.count
    save!
  end

  def copy_mesh_identifier!
    if identifier
      identifiers['mesh'] ||= identifier
      save!
    end
  end

end
