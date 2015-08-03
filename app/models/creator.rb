class Creator < ActiveRecord::Base

  belongs_to :record
  belongs_to :person, counter_cache: :records_count

end
