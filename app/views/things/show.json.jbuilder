json.id @thing.identifier
json.(@thing, :title)
json.authors @thing.people.each do |person|
  json.id person.to_param
  json.(person, :name)
end
json.subjects @thing.subjects.each do |subject|
  json.id subject.to_param
  json.(subject, :label, :description)
end

json.images @thing.image_urls.each do |image_url|
  json.url image_url
end

json.(@thing, :summary, :about)
