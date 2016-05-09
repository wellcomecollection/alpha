require 'open-uri'

class UpdateMetadataFromLiveSiteJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    time_started = Time.now
    success = false

    file = open("http://search.wellcomelibrary.org/iii/encore/record/C__R#{record.identifier[0..-2]}?lang=eng&marcData=Y")

    text  = file.read

    if text == "null"
      # Ignore - MARC data not available yet.
    else

      success = true

      fields = {}
      leader = nil

      text.gsub(/\n\s{7}/, '').strip.split("\n").each do |line|

        case line
        when /\ALEADER\s/
         leader = line[7..-1]
        when /\A\d{3}[\s\d]{4}/

          code = line[0..2]
          content = line[7..-1]

          fields[code] ||= []

          if code =~ /\A00\d\z/  # 00x = control fields, no subfields

            fields[code] << content

          else
            content = "|a" + content

            subfields = {}

            content.scan(/\|([a-z0-9])([^\|]+)/).each do |match|
              subfields[match[0]] = match[1].strip
            end

            subfields["ind1"] = line[4]
            subfields["ind2"] = line[5]

            fields[code] << subfields

          end

        else
          raise "Unexpected content: #{line}"
        end

      end

      record.leader = leader
      record.metadata = fields

      record_changed = record.changed?
      record.save!

      if record_changed
        UpdateCreatorsFromMetadataJob.perform_later(record)
        UpdatePeopleAsSubjectsFromRecordsJob.perform_later(record)
        UpdateTaggingsFromMetadataJob.perform_later(record)
        AddToCollectionFromDigCodeJob.perform_later(record)
        UpdateTypesFromMetadataJob.perform_later(record)
      end

    end

    puts "measure\#metadata_refresh.duration=#{(Time.now - time_started)*1000}ms count\#metadata_refresh.count=#{success ? 1 : 0}"

    return nil
  end
end
