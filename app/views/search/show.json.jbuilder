json.records @records.each do |record|
  json.id record.identifier
  json.title record.title
end
