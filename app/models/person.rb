class Person < ActiveRecord::Base

  has_many :creators
  has_many :records, through: :creators

  def to_param
    "P#{id}"
  end

end
