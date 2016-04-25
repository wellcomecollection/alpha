class Type < ActiveRecord::Base

  has_many :record_types, dependent: :destroy
  has_many :records, through: :record_types


  def to_param
    "T#{id}"
  end

  def self.find_by_reference(reference)
    find_by(["? = ANY(types.references)", reference])
  end

end
