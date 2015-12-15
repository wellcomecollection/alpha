require 'nokogiri'

class MarcIngester

  def initialize(filename, optimize_for_insert = true)
    @filename = filename
    @optimize_for_insert = optimize_for_insert
  end

  def ingest!

    files = 0
    records_count = 0
    new_records_count = 0

    file = File.open("import/#{@filename}")

    puts "File opened"

    document = Nokogiri::XML::Document.parse(file)

    puts "Parsed"

    record_elements = document.xpath('//marc:record')
    records_count += record_elements.length

    record_elements.each_with_index do |record_element, index|

      marc_record = MarcRecord.new(record_element)

      attributes = {identifier: marc_record.id, title: marc_record.title,
        metadata: marc_record.metadata, leader: marc_record.leader}


      if @optimize_for_insert

        # In this mode the code tries to insert the record, and falls back to finding and updating
        # the existing record if the insert fails a uniqueness index on the id.

        begin
          Record.create!(attributes)
        rescue ActiveRecord::RecordNotUnique
          record = Record.find_by!(identifier: marc_record.id)
          record.attributes = attributes
          record.save!
        end

      else

        # In this mode the code always looks for an existing record first, before deciding whether
        # to insert or update.

        record = Record.find_or_initialize_by(identifier: marc_record.id)
        record.attributes = attributes

        new_records_count += 1 if record.new_record?

        record.save!

      end

      print "\r#{index+1}/#{records_count} records processed (#{new_records_count} new records found)"
      STDOUT.flush

    end

    STDOUT.flush

  end

end
