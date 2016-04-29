require 'elasticsearch'
class CollectionsSearchController < ApplicationController

  def show

    @name = params[:name]

    search_results = search(@name, @per_page, @from)

    @collections = search_results['hits']['hits']

    @total_count = search_results['hits']['total']

    respond_to do |format|
      format.html do
        if (@collections.length == 1)
          redirect_to collection_path(@collections.first['_source']['slug'])
        else
          render 'collections/search_results'
        end
      end
    end
  end

  private

  def search(name, limit = 50, from = 0)
    client = Elasticsearch::Client.new


    results = client.search index: 'collections',
      body: {
        query: {
          multi_match: {
            query: name,
            fields: ['all_names', 'description']
          }
        },
        highlight: {
          fragment_size: 200,
          fields: {
            name: {},
            description: {}
          }
        },
        size: limit
      }


  end

end
