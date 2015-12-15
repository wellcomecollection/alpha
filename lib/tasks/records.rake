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

end