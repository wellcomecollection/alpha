class RecordType < ActiveRecord::Base

  belongs_to :type, counter_cache: :records_count
  belongs_to :record

end
