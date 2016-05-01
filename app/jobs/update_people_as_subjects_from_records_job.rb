class UpdatePeopleAsSubjectsFromRecordsJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    name_regex = /\A([^\,]+)\,\s?([^\,]+)\z/
    date_regex = /(\d{4})?\-(\d{4})?/

    record.metadata.fetch('600', []).each do |field|

      id = field['0']
      personal_name = field.fetch('a', '').strip.gsub(/\,\z/, '').gsub(/([a-z])\./, '\1')
      numeration = field['b']
      title = field['c']
      dates = field['d']
      attribution_qualifier = field['j']
      fuller_name = field['q']
      affiliation = field['u']
      ind2 = field['ind2']

      if field['ind1'] == '1' && name_regex.match(personal_name)

        forename = personal_name[name_regex, 2]
        surname = personal_name[name_regex, 1]

        name = "#{forename} #{surname}"
      else
        name = personal_name
      end

      if dates
        born_in = dates[date_regex, 1]
        died_in = dates[date_regex, 2]
      end

      all_names = []

      all_names << fuller_name if fuller_name
      all_names << "#{title} #{name}" if title
      all_names << "#{name} #{numeration}" if numeration
      all_names << "#{attribution_qualifier} #{name}" if attribution_qualifier

      person = Person.find_by_id_or_name_and_dates(id, name, born_in, died_in) || Person.new

      person.name ||= name
      person.born_in ||= born_in
      person.died_in ||= died_in
      person.all_names = (person.all_names.to_a + [name]).uniq

      if id && person.identifiers['loc'].blank?
        person.identifiers['loc'] = id
      end

      person.save!

      person_as_subject = record.person_as_subjects.new(person: person)
      person_as_subject.as = name

      begin
        person_as_subject.save!
      rescue ActiveRecord::RecordNotUnique
        # Already added
      end

    end

    nil
  end
end
