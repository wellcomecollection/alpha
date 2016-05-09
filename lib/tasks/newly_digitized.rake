require 'open-uri'
require 'json'

namespace :discover do

  desc 'Import newly digitized records'
  task newly_digitized: :environment do

    time_started = Time.now

    newly_digitized_count = 0

    # 'IIF' JSON-LD file of records digitized in past week
    url = 'http://wellcomelibrary.org/service/collections/recently-digitised/week/'

    response = JSON.parse(open(url).read)

    response['manifests'].each do |manifest|

      b_number = manifest['@id'].scan(/b[\dx]+/).first
      digitized_date = Time.parse(manifest['navDate'])
      title = manifest['label']

      record = Record.select(:id, :digitized, :digitized_at).find_by(identifier: b_number) ||
        Record.new(identifier: b_number, digitized: false, title: title)


      if record.digitized == false

        if digitized_date > Time.new(1990, 01, 01) && record.digitized_at.nil?
          record.digitized_at = digitized_date
        end

        record.save!

        DownloadPackageJob.perform_later(record)
        newly_digitized_count += 1
      end

    end

    # This line is used by Librato / other tools for metrics
    puts "measure\#newly_digitized.duration=#{(Time.now - time_started)*1000}ms count\#newly_digitized.count=#{newly_digitized_count}"

  end

end