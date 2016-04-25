class AddToCollectionFromDigCodeJob < ActiveJob::Base
  queue_as :default

  DIG_CODES = {
    'diggentics' => 'Genetics',
    'digukmhl' => '',
    'digmhl(nlm)' => '',
    'digrecipe' => 'Recipes',
    'digtdnet' => '',
    'digmoh' => 'Ministry of Health reports',
    'digmhl(francis)' => '',
    'digmhl(cushing)' => '',
    'dig19th' => '',
    'digglasgow' => '',
    'digaids' => '',
    'digmhl(columbia)' => '',
    'digmhl(gerstein)' => '',
    'digucl(ophta)' => '',
    'digramc' => '',
    'diglshtm' => '',
    'digfilm' => '',
    'digarabic' => '',
    'digasylum' => '',
    'digrcpe' => '',
    'digthomson' => '',
    'digleeds' => '',
  }

  def perform(record)

    local_codes = record.metadata.fetch('759', []).map {|field| field['a'].to_s.strip }

    local_codes.each do |local_code|

      if DIG_CODES[local_code]

        collection = Collection.find_by_dig_code(local_code) ||
          Collection.create!(dig_code: local_code, name: DIG_CODES[local_code])

        begin
          record.collections << collection
        rescue ActiveRecord::RecordNotUnique
          # Already added - ignore.
        end

      end

    end


  end
end
