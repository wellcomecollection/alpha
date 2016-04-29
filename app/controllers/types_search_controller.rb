require 'elasticsearch'
class TypesSearchController < ApplicationController

  def show

    @q = params[:q]

    search_results = search(@q)

    @types = search_results['hits']['hits']

    @total_count = search_results['hits']['total']

    respond_to do |format|
      format.html do
        if (@types.length == 1)
          redirect_to type_path(@types.first['_source']['id'])
        else
          render 'types/search_results'
        end
      end
    end
  end

  private

  def search(q, limit = 50, from = 0)
    client = Elasticsearch::Client.new(log: true)


    results = client.search index: 'types',
      body: {
        query: {
          multi_match: {
            query: q,
            fields: ['all_names', 'description']
          }
        },
        size: limit
      }


  end

end
