class TypesController < ApplicationController

  def index

    @order = params[:order].to_s
    @order = 'digitized' if @order.blank?

    order = @order == 'records' ? 'records_count' : 'digitized_records_count'

    @types = Type.order("#{order} desc")
  end

  def show
    @type = Type.find(params[:id].gsub('T',''))

    client = Elasticsearch::Client.new

    results = client.search index: 'records',
      size: 200,
      body: {
        query: {
          match: {
            type_ids: @type.id
          }
        },
        sort: [{digitized: {order: 'desc'}}],
        aggs: {
          people: {
            terms: {
              field: 'person_ids',
              size: 16
            }
          }, subjects: {
            terms: {
              field: 'subject_ids',
              size: 16
            }
          }, years: {
            terms: {
              field: 'year',
              size: 0 # all buckets please
            }
          }
        }
      }

    people_ids = results['aggregations']['people']['buckets'].collect {|result| result['key'] }

    @year_counts = results['aggregations']['years']['buckets']
      .map { |h| h.values_at('key', 'doc_count') }
      .sort
      .to_h

    @people = Person
      .find(people_ids)

    subject_ids = results['aggregations']['subjects']['buckets'].collect {|result| result['key'] }

    @subjects = Subject
      .find(subject_ids)

    @records = results['hits']['hits'].collect do |hit|

      Record.new(
        identifier: hit['_id'],
        title: hit['_source']['title'],
        cover_image_uris: hit['_source']['cover_image_uris'],
      )
    end

  end

end
