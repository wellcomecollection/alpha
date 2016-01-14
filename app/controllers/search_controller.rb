class SearchController < ApplicationController

  def show

    @query = params[:q]
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
        size: @per_page,
        from: @from
      }


    @records = results['hits']['hits']
    @total_count = results['hits']['total']

  end

end
