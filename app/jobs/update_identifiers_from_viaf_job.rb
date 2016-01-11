class UpdateIdentifiersFromViafJob < ActiveJob::Base
  queue_as :default

  def perform(person)

    wikipedia_url_regxex = /\Ahttp\:\/\/([^\.]+).wikipedia.org\/wiki\/(.+)\z/

    loc_identifier = person.identifiers['loc']

    if loc_identifier

      url = URI.escape("http://viaf.org/viaf/sourceID/LC%7C#{loc_identifier}/justlinks.json")

      begin
        open(url) do |file|

          viaf_concordances = JSON.parse(file.read)

          person.identifiers['viaf'] = viaf_concordances["viafID"]

          viaf_concordances.except("viafID", "LC", "Wikipedia").each_pair do |key, value|
            person.identifiers[key.downcase] = value.to_a.first
          end

          viaf_concordances["Wikipedia"].to_a.each do |wikipedia_url|

            wikipedia_language = wikipedia_url[wikipedia_url_regxex, 1]
            wikipedia_slug = wikipedia_url[wikipedia_url_regxex, 2]

            person.identifiers["wikipedia_#{wikipedia_language}"] = wikipedia_slug

          end

          person.save!

        end

      rescue OpenURI::HTTPError
        puts "Error: #{url}"
        return true
      end

    end

  end

end
