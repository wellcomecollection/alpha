namespace :people do



  desc 'De-normalise people (aka authors) from metadata column'
  task denormalize: :environment do

    name_regex = /\A([^\,]+)\,\s?(.+)\z/


    Record.select(:id, :metadata).where("metadata ? '100'").find_each(batch_size: 500) do |record|

      record.metadata['100'].each do |name_field|

        id = name_field['0']
        name = name_field['a'].strip.gsub(/\,\z/, '')
        all_names = [name]

        if name_field['ind1'] == '1' && name_regex.match(name)

          forename = name[name_regex, 2]
          surname = name[name_regex, 1]

          name = "#{forename} #{surname}"
          all_names << name

        end

        numeration = name_field['b']
        title = name_field['c']
        dates = name_field['d']
        relator = name_field['e']
        fuller_name = name_field['q']

        all_names << fuller_name if fuller_name
        all_names << "#{name}, #{relator}" if relator
        all_names << "#{title} #{name}" if title


        date_regex = /(\d{4})?\-(\d{4})?/

        if dates
          born_in = dates[date_regex, 1]
          died_in = dates[date_regex, 2]
        end

        if id.blank?
          # Don't do anything yet.
        else

          person = Person.where(["identifiers->'loc' = ? ", id]).take ||
            Person.new(identifiers: {'loc' => id})

          person.name ||= name
          person.all_names = (person.all_names.to_a + all_names).uniq
          person.born_in ||= born_in
          person.died_in ||= died_in

          person.save!

          creator = record.creators.new(person: person)
          creator.as = name

          begin
            creator.save!
          rescue ActiveRecord::RecordNotUnique
          end

        end


      end

    end

  end

end
