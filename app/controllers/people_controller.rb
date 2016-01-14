class PeopleController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @top_people = Person
      .where("array_length(wikipedia_images, 1) > 0")
      .where('records_count > 4')
      .order('random()').limit(200)
  end

  def edit
    @person = Person.find(params[:id].gsub('P', ''))
  end

  def show

    id = params[:id].gsub("P", "")

    @person = Person.find(id)

    @digitized_count = @person.records.where(digitized: true).count

    record_ids = @person.records.select(:id)

    if @person.born_in

      born_in_range = (@person.born_in - 10)..(@person.born_in + 10)

      subject_ids = Tagging.select(:subject_id).where("record_id IN (#{record_ids.to_sql})")
      subject_record_ids = Tagging.select(:record_id).where("subject_id IN (#{subject_ids.to_sql})")
      subject_people_ids = Creator.select(:person_id).where("record_id IN (#{subject_record_ids.to_sql})")

      @contemporaries = Person
        .where(born_in: born_in_range)
        .where.not(id: @person.id)
        .where("id IN (#{subject_people_ids.to_sql})")
        .order('records_count desc')
        .limit(10)

    end

    @publication_years = Record
      .select('year')
      .where("records.id IN (#{record_ids.to_sql})")
      .where.not(year: nil)
      .group('year')
      .order('year')
      .count

    @top_subjects_written_about = Subject
      .joins(:taggings)
      .select("subjects.*, count(taggings.id) as count")
      .where("taggings.record_id IN (#{record_ids.to_sql})")
      .group('subjects.id')
      .order('count desc')
      .limit(40)

    @things = @person.records.select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .order('digitized desc')
      .limit(100)
  end

  def update
    @person = Person.find(params[:id].gsub('P', ''))
    @person.update_attributes(person_params)
    redirect_to person_url(@person)
  end

  private

  def person_params
    params.require(:person).permit(:highlighted)
  end

end
