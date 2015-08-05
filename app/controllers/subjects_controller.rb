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

    @people_whove_written_about_it = Person
      .joins(:creators)
      .select("people.*, count(creators.id) as count")
      .where(creators: {record_id: thing_ids})
      .group('people.id')
      .order('count desc')
      .limit(20)

    @related_subjects = Subject
      .joins(:taggings)
      .select("subjects.*, count(subjects.id) as count")
      .where(taggings: {record_id: thing_ids})
      .where.not(id: @subject.id)
      .group('subjects.id')
      .order('count desc')
      .limit(10)


  end

end
