class SubjectsController < ApplicationController

  def index
    @top_subjects = Subject
      .order('records_count desc')
      .limit(200)
  end

  def show
    id = params[:id].gsub('S','')

    @subject = Subject.find(id)

    @things = @subject.records.select(:identifier, :title, :package)
      .order('digitized desc')
      .limit(100)


    thing_ids = @subject.records.pluck(:id)

    @people_whove_written_about_it = Creator
      .joins(:person)
      .select("people.*, count(creators.id) as count")
      .where(record_id: thing_ids)
      .group('people.id')
      .order('count desc')
      .limit(20)

  end

end
