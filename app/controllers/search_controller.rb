class SearchController < ApplicationController

  def show

    @query = params[:q].to_s

    if !@query.blank?

      @per_page = params[:limit].to_i
      @per_page = 200 unless (1..200).include?(@per_page)
      @from = params[:from].to_i

      client = Elasticsearch::Client.new log: true

      results = client.search index: 'records',
        body: {
          query: {
            match: {
              '_all' => {
                query: @query,
                operator: 'and'
              }
            }
          },
          sort: [{digitized: {order: 'desc'}}],
          size: @per_page,
          from: @from
        }


      @records = results['hits']['hits'].collect do |record|

        Record.new(
          identifier: record['_id'],
          title: record['_source']['title'],
          cover_image_uris: record['_source']['cover_image_uris'],
          pdf_thumbnail_url: record['_source']['pdf_thumbnail_url'],

        )
      end

      @total_count = results['hits']['total']

    end

  end

end
