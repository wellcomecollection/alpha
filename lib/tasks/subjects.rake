namespace :subjects do



  task update_records_count: :environment do

    $stdout.sync = true

    time = Time.now

    Subject.select(:id)
      .find_in_batches(batch_size: 5000)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |subject|
        subject.update_records_count!
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end

  task import_from_records: :environment do

    $stdout.sync = true

    time = Time.now

    Record.select(:id, :metadata)
      .find_in_batches(batch_size: 500)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |record|
        record.update_taggings_from_metadata!
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end


  desc 'Copy mesh IDs into identifiers'
  task set_mesh_ids: :environment do

    $stdout.sync = true

    time = Time.now

    Subject.select(:id, :identifier, :identifiers)
      .find_in_batches(batch_size: 500)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |subject|
        subject.copy_mesh_identifier!
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end

end
