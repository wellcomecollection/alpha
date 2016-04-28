class TypePeopleController < ApplicationController

  def index
    @type = Type.find(params[:type_id].gsub('T', ''))

    client = Elasticsearch::Client.new

    @people_results = client.search index: 'records',
      size: 0, # no hits please
      body: {
        query: {
          match: {
            type_ids: @type.id
          }
        },
        aggs: {
          people: {
            terms: {
              field: :person_ids,
              size: 60
            }
          }
        }
      }

    @people_results = @people_results['aggregations']['people']['buckets']

    people_ids = @people_results.collect {|result| result['key'] }

    @people = Person
      .find(people_ids)
  end

  def show
    @type = Type.find(params[:type_id].gsub('T', ''))
    @person = Person.find(params[:id].gsub('P', ''))

    @records = @type.records
      .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .joins(:creators)
      .where(creators: {person: @person.id})
      .order(:digitized).reverse_order
      .limit(100)
  end

end
