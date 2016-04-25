namespace :types do

  task update_digitized_records_count: :environment do

    Type.select(:id).find_each do |record_type|
      record_type.update_digitized_records_count!
    end

  end


end
