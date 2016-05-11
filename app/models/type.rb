class Type < ActiveRecord::Base

  has_many :record_types, dependent: :destroy
  has_many :records, through: :record_types

  scope :highlighted, -> { where(highlighted: true) }


  def to_param
    "T#{id}"
  end

  def self.find_by_reference(reference)
    find_by(["? = ANY(types.references)", reference])
  end

  def update_digitized_records_count!
    update_attribute(:digitized_records_count, records.digitized.count)
  end

  def to_elasticsearch
    {
      name: name,
      description: description,
      all_names: [name],
      records_count: records_count,
      digitized_records_count: digitized_records_count
    }
  end

end
