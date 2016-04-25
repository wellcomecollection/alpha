class Collection < ActiveRecord::Base

  has_many :collection_memberships, dependent: :destroy
  has_many :records, through: :collection_memberships

end
