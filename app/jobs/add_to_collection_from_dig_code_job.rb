class AddToCollectionFromDigCodeJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    local_codes = record.metadata.fetch('759', []).map {|field| field['a'].to_s }

    local_codes.each do |local_code|

      if local_code =~ /\Adig/

        collection = Collection.find_by_dig_code(local_code) ||
          Collection.create!(dig_code: local_code, name: local_code)

        begin
          record.collections << collection
        rescue ActiveRecord::RecordNotUnique
          # Already added - ignore.
        end

      end

    end


  end
end
