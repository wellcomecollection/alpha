class Creator < ActiveRecord::Base

  belongs_to :record, counter_cache: :creators_count
  belongs_to :person, counter_cache: :records_count

end
