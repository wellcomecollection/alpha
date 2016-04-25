class Collection < ActiveRecord::Base

  has_many :collection_memberships, dependent: :destroy
  has_many :records, through: :collection_memberships

  def update_digitized_records_count!
    update_attribute(:digitized_records_count, records.digitized.count)
  end

end
