class Creator < ActiveRecord::Base

  belongs_to :record, counter_cache: :creators_count
  belongs_to :person, counter_cache: :records_count

  has_many :collection_memberships, primary_key: :record_id, foreign_key: :record_id
  has_many :record_types, primary_key: :record_id, foreign_key: :record_id

end
