class Tagging < ActiveRecord::Base

  belongs_to :subject, counter_cache: :records_count
  belongs_to :record

  has_many :collection_memberships, primary_key: :record_id, foreign_key: :record_id
  has_many :record_types, primary_key: :record_id, foreign_key: :record_id


end
