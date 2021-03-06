class SubjectsController < ApplicationController

  before_filter :authorize, except: ['show', 'index', 'multiple']

  def index
    @from = params[:from].to_i.abs

    @per_page = 200

    @highlighted_subjects = Subject.highlighted
      .order('random()')

    @top_subjects = Subject
      .order('records_count desc')
      .offset(@from)
      .limit(@per_page)

    @total_subjects_count = Subject.count

  end

  def show
    id = params[:id].gsub('S','')
    @year = params[:year]

    @subject = Subject.find(id)

    @things = @subject.records.select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .where(digitized: true)
      .limit(100)
    @things = @things.where(year: @year) if @year.present?

    if @things.length < 100
      more_things = @subject.records.select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
        .where(digitized: false)
        .limit(100 - @things.length)
      more_things = more_things.where(year: @year) if @year.present?

      @things = @things.to_a + more_things.to_a
    end

    subselect =
      if @year.present?
        'select taggings.record_id from taggings inner join records on records.id = taggings.record_id where taggings.subject_id = ? and records.year = ?'
      else
        'select taggings.record_id from taggings where taggings.subject_id = ?'
      end

    @people_whove_written_about_it = Person
      .joins(:creators)
      .select("people.*, count(creators.id) as count")
      .where(["creators.record_id IN (#{subselect})", @subject.id, @year].compact)
      .group('people.id')
      .order('count desc')
      .limit(36)

    @related_subjects = Subject
      .joins(:taggings)
      .select("subjects.*, count(subjects.id) as count")
      .where(["taggings.record_id IN (#{subselect})", @subject.id, @year].compact)
      .where.not(id: @subject.id)
      .group('subjects.id')
      .order('count desc')
      .limit(15)

    client = Elasticsearch::Client.new

    results = client.search index: 'records',
      size: 0, # no hits please
      body: {
        query: {
          match: {
            subject_ids: @subject.id
          }
        },
        aggs: {
          years: {
            terms: {
              field: 'year',
              size: 0 # all buckets please
            }
          }
        }
      }

    @year_counts = results['aggregations']['years']['buckets']
      .map { |h| h.values_at('key', 'doc_count') }
      .sort
      .to_h

    if @year.present?
      @records_count = @year_counts[@year] || 0
      @digitized_records_count = @subject.records.where(year: @year, digitized: true).count
    else
      @records_count = @subject.records_count
      @digitized_records_count = @subject.digitized_records_count
    end

    @trees = []

    @narrower_subjects = []

    @subject.tree_numbers.to_a.each do |tree_number|

      parent_tree_numbers = []

      while !tree_number.blank?

        tree_number = tree_number.gsub(/\.?[^\/\.]+\z/, '')
        parent_tree_numbers << tree_number unless tree_number.blank?

      end

      if parent_tree_numbers.length > 0

        @trees << Subject.select('*')
        .from("(select *, unnest(tree_numbers) as tree_number from subjects) as subjects")
        .where(tree_number: parent_tree_numbers)
        .order(:tree_number)
      end
    end

    @subject.tree_numbers.to_a.each do |tree_number|

      Subject.select('*')
        .from("(select id, records_count, label, unnest(tree_numbers) as tree_number from subjects) as subjects")
        .where(["tree_number LIKE ?", tree_number + '.%'])
        .order('records_count desc')
        .limit(10)
        .each do |subject|

        @narrower_subjects << subject unless @narrower_subjects.include?(subject)

      end

    end

    @types = Type
      .select(['types.id', 'types.name'])
      .select('count(record_types.record_id) as records_in_type_count')
      .joins(record_types: [:taggings])
      .where(taggings: {subject_id: @subject.id})
      .group('types.id')
      .order('records_in_type_count desc')
      .limit(20)

  end

  def multiple

    @subjects = Subject.find(params[:id].split('+').collect {|id| id.gsub('S', '') } )

    subject_ids = @subjects.collect(&:id)

    @records = Record.joins(:taggings).having(["array_agg(taggings.subject_id) @> ARRAY[?]", subject_ids])
      .where(taggings: {subject_id: subject_ids}).order('records.digitized desc').group('records.id').limit(10)

  end

  def update

    @subject = Subject.find(params[:id].gsub('S', ''))

    @subject.update_attributes(subject_params)

    redirect_to subject_url(@subject)
  end

  private

  def subject_params
    params.require(:subject).permit(:highlighted)
  end

end
