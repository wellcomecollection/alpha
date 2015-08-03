require 'open-uri'
require 'json'

class Person < ActiveRecord::Base

  has_many :creators
  has_many :records, through: :creators

  def to_param
    "P#{id}"
  end

  def set_other_identifiers_from_viaf!

    wikipedia_url_regxex = /\Ahttp\:\/\/([^\.]+).wikipedia.org\/wiki\/(.+)\z/

    if identifiers['loc']

      url = URI.escape("http://viaf.org/viaf/sourceID/LC%7C#{identifiers['loc']}/justlinks.json")

      open(url) do |file|

        viaf_concordances = JSON.parse(file.read)

        identifiers['viaf'] = viaf_concordances["viafID"]

        viaf_concordances.except("viafID", "LC", "Wikipedia").each_pair do |key, value|
          identifiers[key.downcase] ||= value.to_a.first
        end

        viaf_concordances["Wikipedia"].to_a.each do |wikipedia_url|

          wikipedia_language = wikipedia_url[wikipedia_url_regxex, 1]
          wikipedia_slug = wikipedia_url[wikipedia_url_regxex, 2]

          identifiers["wikipedia_#{wikipedia_language}"] ||= wikipedia_slug

        end

        save!

      end

    end

  end

end
