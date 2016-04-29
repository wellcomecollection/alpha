module ApplicationHelper


  def catalogue_name(key)

    case key
    when 'loc'
      "Library of Congress"
    when 'wkp'
      "Wikidata"
    when 'mesh'
      "Medical Subject Headings"
    when 'bnf'
      "Bibliothèque nationale de France"
    when 'isni'
      "International Standard Name Identifier"
    when 'nta'
      "Koninklijke Bibliotheek"
    when 'dnb'
      "Deutsche Nationalbibliothek"
    when 'bav'
      "Biblioteca Apostolica Vaticana"
    when 'nla'
      "National Library of Australia"
    when 'n6i'
      "National Library of Ireland"
    when 'nli'
      "National Library of Israel"
    when 'iccu'
      "Istituto centrale per il Catalogo unico delle biblioteche italiane e per le informazioni bibliografiche"
	when 'viaf'
	  "Virtual International Authority File"
	when 'nukat'
	  "Centrum NUKAT Biblioteki Uniwersyteckiej w Warszawie"
	when 'ptbnp'
	  "Biblioteca Nacional de Portugal"
	when 'sudoc'
	  "Système Universitaire de Documentation"
	when 'selibr'
	  "Kungliga biblioteket - Sveriges nationalbibliotek"
	when 'nkc'
	  "Národní knihovna České republiky"
	when 'rero'
	  "Réseau des bibliothèques de Suisse occidentale"
	when 'lac'
	  "Library and Archives Canada"
	when 'jpg'
	  "Getty Research Institute"
	when 'nlp'
	  "Biblioteka Narodowa"
	when 'bne'
	  "Biblioteca Nacional de España"
	when 'imagine'
	  "מוזיאון ישראל"
	when 'b2q'
	  "Bibliothèque et Archives nationales du Québec"
	when 'bnc'
	  "Biblioteca de Catalunya"
	when 'ndl'
	  "国立国会図書館"
    else
      key
    end

  end


  def library_person_link(key, value)

    case key
    when 'viaf'
      "http://viaf.org/viaf/#{value}/"
    when 'isni'
      "http://isni.org/viaf/#{value}/"
    when 'loc'
      "http://id.loc.gov/authorities/names/#{value.gsub(/\s+/, '')}.html"
    when 'bnf', 'dnb', 'imagine'
      value
    when 'wkp'
      "https://www.wikidata.org/wiki/#{value}"
    when /wikipedia_([a-z]{2})/
      "https://#{Regexp.last_match(1)}.wikipedia.org/wiki/#{value}"
    else
      nil
    end


  end

  def library_subject_link(key, value)

    case key
    when 'loc'
      "http://id.loc.gov/authorities/subjects/#{value.gsub(/\s+/, '')}.html"
    when 'mesh'
	  "https://wellcome-mesh-browser.herokuapp.com/#{value}"
    else
      nil
    end


  end


  def digitized_graph(digitized_records_count, records_count)

    "<div class=\"lil-vis\" style=\"margin-top: -7px; margin-bottom: 0;\">
      <div class=\"digitised\" style=\"margin-top: -11px; margin-bottom: 0;\">
      <div class=\"percent-done\" style=\"width: #{(100 * digitized_records_count.to_f / records_count) }%;\">&nbsp;</div>
      </div>
    </div>".html_safe
  end

end
