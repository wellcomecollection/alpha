namespace :people do


  desc 'Update data from Wikipedia'
  task remove_full_stops: :environment do

    $stdout.sync = true

    Person.select(:id, :name, :all_names)
      .find_each do |person|
        person.remove_full_stops_from_name!
    end

  end


  desc 'Queues all people for an update from Wikipedia'
  task queue_all_for_update_from_wikipedia: :environment do

    $stdout.sync = true

    time = Time.now

    Person.where("identifiers ? 'wikipedia_en'")
      .find_in_batches(batch_size: 500)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |person|
        UpdatePersonFromWikipediaJob.perform_later(person)
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end


  desc 'Get identifiers from VIAF'
  task get_identifiers: :environment do

    $stdout.sync = true

    time = Time.now

    Person.select(:id, :identifiers)
      .find_in_batches(batch_size: 500).with_index do |batch, batch_number|

        print "Processing batch #{batch_number + 1}... "

        batch.each do |person|
          person.set_other_identifiers_from_viaf!
        end

        puts "Done in #{Time.now - time} seconds"
        time = Time.now

    end

  end


  desc 'De-normalise people (aka authors) from metadata column'
  task denormalize: :environment do

    $stdout.sync = true

    name_regex = /\A([^\,]+)\,\s?(.+)\z/


    time = Time.now

    Record.select(:id, :metadata)
      .find_in_batches(batch_size: 500).with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |record|


        ( record.metadata.fetch('100', []) +
          record.metadata.fetch('700', [])
        ).each do |name_field|

          id = name_field['0']
          name = name_field.fetch('a', '').strip.gsub(/\,\z/, '').gsub(/([a-z])\./, '\1')

          all_names = []
          all_names << name unless name.blank?

          if name_field['ind1'] == '1' && name_regex.match(name)

            forename = name[name_regex, 2]
            surname = name[name_regex, 1]

            name = "#{forename} #{surname}"
            all_names << name

          end

          numeration = name_field['b']
          title = name_field['c']
          dates = name_field['d']
          relator = name_field['e']
          fuller_name = name_field['q']

          all_names << fuller_name if fuller_name
          all_names << "#{name}, #{relator}" if relator
          all_names << "#{title} #{name}" if title


          date_regex = /(\d{4})?\-(\d{4})?/

          if dates
            born_in = dates[date_regex, 1]
            died_in = dates[date_regex, 2]
          end

          if id.blank?

            person = Person.where(["LOWER(name) = ?", name.downcase]).order('records_count desc').take ||
              Person.new

          else
            person = Person.where(["identifiers->'loc' = ? ", id]).take ||
              Person.new(identifiers: {'loc' => id})
          end

          person.name ||= name
          person.all_names = (person.all_names.to_a + all_names).uniq
          person.born_in ||= born_in
          person.died_in ||= died_in

          person.save!

          creator = record.creators.new(person: person)
          creator.as = name

          begin
            creator.save!
          rescue ActiveRecord::RecordNotUnique
          end


        end


      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now
    end

  end

end
