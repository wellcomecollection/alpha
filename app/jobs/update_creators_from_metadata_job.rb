class UpdateCreatorsFromMetadataJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    name_regex = /\A([^\,]+)\,\s?(.+)\z/
    date_regex = /(\d{4})?\-(\d{4})?/

    author_records = (
      record.metadata.fetch('100', []) +
      record.metadata.fetch('700', [])
    )

    updated_people_ids = []

    author_records.each do |author_record|

      all_names = []

      id = author_record['0']
      personal_name = author_record.fetch('a', '').strip.gsub(/\,\z/, '').gsub(/([a-z])\./, '\1')
      numeration = author_record['b']
      title = author_record['c']
      dates = author_record['d']
      attribution_qualifier = author_record['j']
      fuller_name = author_record['q']
      affiliation = author_record['u']

      if author_record['ind1'] == '1' && name_regex.match(personal_name)

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

      # Bugfix for old error with names being truncated by 1 character
      if person.name.length == (name.length - 1)

        puts "Changed #{person.name} to #{name}"
        person.name = name

        raise
      end

      person.born_in ||= born_in
      person.died_in ||= died_in
      person.all_names = (person.all_names.to_a + [name]).uniq

      if id && person.identifiers['loc'] != id
        person.identifiers['loc'] = id
      end

      person.save!

      updated_people_ids << person.id

      if record.creators.where(person_id: person.id).count == 0

        # Save new creator
        record.creators.new(person: person, as: name).save!
      end

    end


    creators_to_delete = record.creators.where.not(person_id: updated_people_ids)

    if creators_to_delete.size > 0

      creators_to_delete.each do |creator|
        creator.destroy
      end
    end

  end
end
