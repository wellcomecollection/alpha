class SubjectsLookupController < ApplicationController

  def index
    @label = params[:label].to_s
    @per_page = params[:limit].to_i
    @per_page = 200 unless (1..200).include?(@per_page)
    @from = params[:from].to_i

    search_results = search(@label, @per_page, @from)

    @subjects = Subject
      .select(:id, :label, :records_count, :digitized_records_count)
      .where(id: search_results['hits']['hits'].collect {|r| r['_id'].gsub('S', '') })
      .order('records_count desc')

    @total_count = search_results['hits']['total']

    view
  end

  def show
    @label = params[:id]
    @per_page = 200
    @from = params[:from].to_i

    search_results = search(@label, @per_page, @from)

    @subjects = Subject
      .select(:id, :label, :records_count, :digitized_records_count)
      .where(id: search_results['hits']['hits'].collect {|r| r['_id'].gsub('S', '') })
      .order('records_count desc')

    @total_count = search_results['hits']['total']

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


  def search(label, limit = 50, from = 0)
    client = Elasticsearch::Client.new log: true

    results = client.search index: 'subjects',
      body: {
        query: {
          match: {
            all_labels: {
              query: label.downcase,
              operator: 'and'
            }
          }
        },
        sort: [{'records_count' => {'order' => 'desc'}}],
        size: limit,
        from: from
      }
  end

end
