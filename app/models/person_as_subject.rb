class PersonAsSubject < ActiveRecord::Base
  self.table_name = "people_as_subjects"

  belongs_to :person, counter_cache: :records_as_subject_count
  belongs_to :record, counter_cache: :people_as_subjects_count

end
