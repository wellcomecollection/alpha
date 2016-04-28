class TypeSubjectsController < ApplicationController

  def index
    @type = Type.find(params[:type_id].gsub('T', ''))

    client = Elasticsearch::Client.new

    @subject_results = client.search index: 'records',
      size: 0, # no hits please
      body: {
        aggs: {
          top_subjects: {
            terms: {
              field: :subject_ids,
              size: 10
            },
            aggs: {
              top_subject_hits: {
                top_hits: {
                  sort: [{digitized: {order: 'desc'}}],
                  size: 1
                }
              }
            }
          }
        }
      }

    @subject_results = @subject_results['aggregations']['top_subjects']['buckets']

    subject_ids = @subject_results.collect {|result| result['key'] }

    @subjects = Subject
      .find(subject_ids)

  end

  def show
    @type = Type.find(params[:type_id].gsub('T', ''))

    @subject = Subject.find(params[:id].gsub('S',''))

    @records = @type.records
      .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .joins(:taggings)
      .where(taggings: {subject_id: @subject.id})
      .order(:digitized).reverse_order
      .limit(100)
  end

end
