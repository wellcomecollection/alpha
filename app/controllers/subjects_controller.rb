class SubjectsController < ApplicationController

  def index
    @top_subjects = Subject
      .order('records_count desc')
      .limit(200)
  end

  def show
    id = params[:id].gsub('S','')

    @subject = Subject.find(id)
  end

end
