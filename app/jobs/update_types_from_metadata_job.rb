class UpdateTypesFromMetadataJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    genres = record.metadata.fetch('655', [])

    genres.each do |genre|

      genre_name = genre['a'].gsub(/\.\z/, '')

      genre_reference = genre_name.downcase

      if genre_name

        type = Type.find_by_reference(genre_reference) || Type.create!(references: [genre_reference], name: genre_name)

        begin
          record.types << type
        rescue ActiveRecord::RecordNotUnique
          # Already added - ignore.
        end

      end

    end

  end
end
