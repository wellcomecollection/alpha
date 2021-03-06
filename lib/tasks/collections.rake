namespace :collections do

  desc 'Import collections from DIG codes'
  task queue_all_for_import_from_dig_code: :environment do

    time = Time.now

    Record.select(:id)
      .find_in_batches(batch_size: 500)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |record|
        AddToCollectionFromDigCodeJob.perform_later(record)
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end

  desc 'Update digitized_records_count on collections'
  task update_digitized_records_count: :environment do

    Collection.select(:id).find_each do |collection|
      collection.update_digitized_records_count!
    end

  end

  desc 'Update from_and_to_years on collections'
  task update_from_and_to_years: :environment do

    Collection.select(:id).find_each do |collection|
      collection.update_from_and_to_years!
    end

  end


end