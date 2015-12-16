class SubjectsController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @from = params[:from].to_i.abs

    @per_page = 200

    @highlighted_subjects = Subject.highlighted
      .limit(8)
      .order('random()')

    @top_subjects = Subject
      .order('records_count desc')
      .offset(@from)
      .limit(@per_page)

    @total_subjects_count = Subject.count

  end

  def show
    id = params[:id].gsub('S','')

    @subject = Subject.find(id)

    @things = @subject.records.select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .order('digitized desc')
      .limit(100)

    @people_whove_written_about_it = Person
      .joins(:creators)
      .select("people.*, count(creators.id) as count")
      .where(["creators.record_id IN (select taggings.record_id from taggings where taggings.subject_id = ?)", @subject.id])
      .group('people.id')
      .order('count desc')
      .limit(36)

    @related_subjects = Subject
      .joins(:taggings)
      .select("subjects.*, count(subjects.id) as count")
      .where(["taggings.record_id IN (select taggings.record_id from taggings where taggings.subject_id = ?)", @subject.id])
      .where.not(id: @subject.id)
      .group('subjects.id')
      .order('count desc')
      .limit(15)

    # Skip year counts for high record count subjects, for now,
    # until we can improve the query performance.
    if @subject.records_count < 2000
      @year_counts = @subject
        .records
        .group('records.year')
        .order('year')
        .count
    else
      @year_counts = []
    end

    @trees = []

    @narrower_subjects = []

    @subject.tree_numbers.to_a.each do |tree_number|

      parent_tree_numbers = []

      while !tree_number.blank?

        tree_number = tree_number.gsub(/\.?[^\/\.]+\z/, '')
        parent_tree_numbers << tree_number unless tree_number.blank?

      end

      @trees << Subject.select('*')
      .from("(select *, unnest(tree_numbers) as tree_number from subjects) as subjects")
      .where(tree_number: parent_tree_numbers)
      .order(:tree_number)

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

  end

  def update

    @subject = Subject.find(params[:id].gsub('S', ''))

    @subject.update_attributes(subject_params)

    redirect_to subject_path(@subject)
  end

  private

  def subject_params
    params.require(:subject).permit(:highlighted)
  end

end
