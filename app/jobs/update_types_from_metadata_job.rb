class UpdateTypesFromMetadataJob < ActiveJob::Base
  queue_as :default

  MAT_TYPES = {
    'a'=> 'Books',
    'b'=> 'Asian manuscripts',
    'x'=> 'Asian manuscripts',
    'c'=> 'Music',
    'd'=> 'Journals',
    'e'=> 'Maps',
    'f'=> 'Videos',
    'g'=> 'Videorecordings',
    'h'=> 'Archives and manuscripts',
    'i'=> 'Audio',
    's'=> 'Audio',
    'j'=> 'E-journals',
    'k'=> 'Pictures',
    'l'=> 'Ephemera',
    'm'=> 'CD-Roms',
    'n'=> 'Film',
    'p'=> 'Mixed materials',
    'r'=> '3-D objects',
    'q'=> 'Digital images',
    'v'=> 'E-books',
    'w' => 'Wellcome dissertations',
    'z' => 'Websites'
  }

  def perform(record)

    genres = record.metadata.fetch('655', [])

    genres.each do |genre|

      genre_name = genre['a'].to_s.gsub(/\.\z/, '')

      genre_reference = genre_name.downcase

      if !genre_name.blank?

        type = Type.find_by_reference(genre_reference) || Type.create!(references: [genre_reference], name: genre_name)

        begin
          record.types << type
        rescue ActiveRecord::RecordNotUnique
          # Already added - ignore.
        end

      end

    end

    mat_type_codes = record.metadata.fetch('998', []).collect {|m| m['d'] }.compact.uniq

    mat_type_codes.each do |mat_type_code|

      if mat_type = MAT_TYPES[mat_type_code]

        type = Type.find_or_create_by!(name: mat_type)

        begin
          record.types << type
        rescue ActiveRecord::RecordNotUnique
          # Already added - ignore.
        end

      end

    end


  end
end
