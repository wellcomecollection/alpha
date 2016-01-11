class UpdatePersonFromWikipediaJob < ActiveJob::Base
  queue_as :default

  def perform(person)
    person.update_from_wikipedia!
  end
end
