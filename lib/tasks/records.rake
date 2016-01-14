require 'open-uri'

include ActionView::Helpers::DateHelper
namespace :records do

  desc 'Import MARC records'
  task resave: :environment do

    time = Time.now
    batch_size = 500
    total_records_count = Record.count

    records_done = 0

    Rails.logger.level = 2

    Record
      .find_in_batches(batch_size: 500)
      .with_index do |batch, batch_number|

      batch.each do |record|
        record.save
        records_done += 1

        records_left_to_do = total_records_count - records_done
        seconds_left = records_left_to_do * ((Time.now - time) / records_done)

        print "\r(#{records_done}/#{total_records_count} processed) ETA: #{distance_of_time_in_words(Time.now, seconds_left.seconds.from_now)}"
        STDOUT.flush

      end

    end

    puts "Done in #{Time.now - time} seconds"

  end


  desc 'Download packages'
  task queue_download_package_job_for_newly_digitized_things: :environment do
    $stdout.sync = true

    response = open("http://wellcomelibrary.org/resource/collections/access/all-open/")

    regex = /\<http\:\/\/wellcomelibrary\.org\/data\/(b[0-9x]+)\>/

    identifiers = response.read.scan(regex).flatten

    puts "#{identifiers.length} records have been digitized (with open access)"

    records = Record
      .select(:id)
      .where(identifier: identifiers, digitized: false)

    puts "Of those, #{records.length} weren't digitized in our database, so queuing those."

    records.each do |record|
      DownloadPackageJob.perform_later record
    end

  end

  task update_creators_count: :environment do

    $stdout.sync = true

    time = Time.now

    Record
      .find_in_batches(batch_size: 100)
      .with_index do |batch, batch_number|

      print "Processing batch #{batch_number + 1}... "

      batch.each do |record|
        record.update_creators_count!
      end

      puts "Done in #{Time.now - time} seconds"
      time = Time.now

    end

  end

end