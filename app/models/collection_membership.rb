class CollectionMembership < ActiveRecord::Base

  belongs_to :collection, counter_cache: :records_count
  belongs_to :record

end
