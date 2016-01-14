require 'elasticsearch'
class PeopleLookupController < ApplicationController

  def index
    @name = params[:name].to_s
    @per_page = params[:limit].to_i
    @per_page = 200 unless (1..200).include?(@per_page)

    @from = params[:from].to_i

    search_results = search(@name, @per_page, @from)

    @people = Person
      .select(:id, :name, :wikipedia_images, :born_in, :died_in, :records_count)
      .where(id: search_results['hits']['hits'].collect {|r| r['_id'].gsub('P', '') })
      .order('records_count desc')

    @total_count = search_results['hits']['total']

    respond_to do |format|
      format.html do
        if (@people.length == 1)
          redirect_to person_path(@people.first)
        else
          render :show
        end
      end
      format.json { render json: @people.collect(&:to_api) }
    end

  end

  def show
    @name = params[:id]
    @per_page = 200

    @from = 0

    search_results = search(@name, @per_page, @from)

    @people = Person
      .select(:id, :name, :wikipedia_images, :born_in, :died_in, :records_count)
      .where(id: search_results['hits']['hits'].collect {|r| r['_id'].gsub('P', '') })
      .order('records_count desc')

    @total_count = search_results['hits']['total']

    respond_to do |format|
      format.html do
        if (@people.length == 1)
          redirect_to person_path(@people.first)
        else
          render :show
        end
      end
      format.json { render json: @people.collect(&:to_api) }
    end
  end

  private

  def search(name, limit = 50, from = 0)
    client = Elasticsearch::Client.new log: true


    results = client.search index: 'people',
      body: {
        query: {
          match: {
            name: {
              query: name.downcase,
              operator: 'and'
            }
          }
        },
        size: limit
      }


  end

end
