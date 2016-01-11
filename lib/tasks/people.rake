namespace :people do


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

  task update_from_records: :environment do

    $stdout.sync = true

    time = Time.now

    Record.select(:id, :metadata)
      .find_in_batches(batch_size: 500)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |record|
        record.update_people_from_metadata!
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end

end
