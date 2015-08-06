require 'elasticsearch'
class PeopleLookupController < ApplicationController

  def index
    @name = params[:name].to_s
    limit = params[:limit] || 20

    @people = search(@name, limit)

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
    @people = search(@name)
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


  def search(name, limit = 50)
    client = Elasticsearch::Client.new log: true


    results = client.search index: 'people',
      body: {
        query: {
          match: {
            'name' => name.downcase
          }
        },
        size: limit
      }

    Person
      .where(id: results['hits']['hits'].collect {|r| r['_id'].gsub('P', '') })
      .order('records_count desc')
  end

end
