module ApplicationHelper


  def catalogue_name(key)

    case key
    when 'loc'
      "Library of Congress"
    when 'wkp'
      "Wikidata"
    when 'wikipedia_en'
      "English Wikipedia"
    when 'wikipedia_de'
      "German Wikipedia"
    else
      key
    end

  end


  def library_person_link(key, value)

    case key
    when 'viaf'
      "http://viaf.org/viaf/#{value}/"
    when 'loc'
      "http://id.loc.gov/authorities/names/#{value.gsub(/\s+/, '')}.html"
    when 'bnf', 'dnb'
      value
    when 'wkp'
      "https://www.wikidata.org/wiki/#{value}"
    when /wikipedia_([a-z]{2})/
      "https://#{Regexp.last_match(1)}.wikipedia.org/wiki/#{value}"
    else
      nil
    end


  end

end
