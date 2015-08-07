json.id @subject.to_param
json.(@subject, :label, :description, :identifiers, :records_count)
json.digitized_count @digitized_count

json.related @related_subjects.each do |subject|
  json.id subject.to_param
  json.(subject, :label)
  json.count subject.count
end

json.narrower @narrower_subjects.each do |subject|
  json.id subject.to_param
  json.(subject, :label)
end

json.things @things.each do |record|
  json.id record.identifier
  json.(record, :title)
end

json.trees @trees.each do |tree|
  json.subjects tree.each do |subject|
    json.id subject.to_param
    json.(subject, :label, :description, :records_count)
  end
end