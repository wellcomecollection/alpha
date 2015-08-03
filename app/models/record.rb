class Record < ActiveRecord::Base

  has_many :creators
  has_many :people, through: :creators

  def to_param
    identifier
  end

end
