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

end