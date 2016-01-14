json.id @person.to_param
json.(@person, :name, :all_names, :identifiers, :records_count, :born_in, :died_in)
json.digitized_count @digitized_count
json.wikipedia_intro @person.wikipedia_intro_paragraph

json.things @things.each do |record|
  json.id record.identifier
  json.(record, :title)
end