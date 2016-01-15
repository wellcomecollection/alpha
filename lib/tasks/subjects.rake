namespace :subjects do

  task update_digitized_records_count: :environment do

    $stdout.sync = true

    time = Time.now

    Subject.select(:id)
      .find_in_batches(batch_size: 2000)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |subject|
        subject.update_digitized_records_count!
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end


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

    Record.select(:id)
      .find_in_batches(batch_size: 500)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |record|
        UpdateTaggingsFromMetadataJob.perform_later record
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end


  task fix_labels: :environment do

    regex = /\A([^\(\)]+)(\([^\)]+\))([^\(\)]+)\z/

    Subject.where("label LIKE '%(%'").find_each do |subject|

      if subject.label =~ regex

        match = subject.label.match(regex)

        new_label = "#{match[1]} #{match[3]} #{match[2]}".squeeze(' ')

        subject.all_labels << new_label unless subject.all_labels.include?(new_label)

        subject.label = new_label

        subject.save!

      end

    end

  end

end
