require 'elasticsearch'
class PeopleLookupController < ApplicationController

  def index
    @name = params[:name].to_s
    @per_page = params[:limit].to_i
    @per_page = 200 unless (1..200).include?(@per_page)

    @from = params[:from].to_i

    @people = search(@name, @per_page, @from)
    @total_count = count(@name)

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


  def count(name)

    client = Elasticsearch::Client.new log: true

    results = client.count index: 'people',
      body: {
        query: {
          match: {
            'name' => name.downcase
          }
        }
      }

    return results['count']

  end

  def search(name, limit = 50, from = 0)
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

    puts results.inspect

    Person
      .select(:id, :name, :wikipedia_images, :born_in, :died_in, :records_count)
      .where(id: results['hits']['hits'].collect {|r| r['_id'].gsub('P', '') })
      .order('records_count desc')
  end

end
