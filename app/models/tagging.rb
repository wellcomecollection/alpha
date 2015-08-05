class Tagging < ActiveRecord::Base

  belongs_to :subject, counter_cache: :records_count
  belongs_to :record

end
