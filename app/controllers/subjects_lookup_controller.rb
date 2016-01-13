class SubjectsLookupController < ApplicationController

  def index
    @label = params[:label].to_s
    @per_page = params[:limit].to_i
    @per_page = 200 unless (1..200).include?(@per_page)
    @from = params[:from].to_i

    @subjects = search(@label, @per_page, @from)

    @total_count = count(@label)

    view
  end

  def show
    @label = params[:id]
    @per_page = 200
    @from = params[:from].to_i

    @subjects = search(params[:id], @per_page, @from)
    @total_count = count(@label)

    view
  end

  private

  def view
    respond_to do |format|
      format.html do
        if (@subjects.length == 1)
          redirect_to subject_path(@subjects.first)
        else
          render :show
        end
      end
      format.json { render json: @subjects.collect(&:to_api) }
    end
  end

  def count(label)

    client = Elasticsearch::Client.new log: true

    results = client.count index: 'subjects',
      body: {
        query: {
          match: {
            'label' => label.downcase
          }
        }
      }


    puts results.inspect


    return results['count']

  end

  def search(label, limit = 50, from = 0)
    client = Elasticsearch::Client.new log: true

    results = client.search index: 'subjects',
      body: {
        query: {
          match: {
            'label' => label.downcase
          }
        },
        sort: [{'records_count' => {'order' => 'desc'}}],
        size: limit,
        from: from
      }


    Subject
      .select(:id, :label, :records_count, :digitized_records_count)
      .where(id: results['hits']['hits'].collect {|r| r['_id'].gsub('S', '') })
      .order('records_count desc')
  end

end
