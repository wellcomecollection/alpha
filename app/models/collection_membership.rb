class CollectionMembership < ActiveRecord::Base

  belongs_to :collection, counter_cache: :records_count
  belongs_to :record

  has_many :creators, primary_key: :record_id, foreign_key: :record_id
  has_many :taggings, primary_key: :record_id, foreign_key: :record_id
  has_many :record_types, primary_key: :record_id, foreign_key: :record_id

end
