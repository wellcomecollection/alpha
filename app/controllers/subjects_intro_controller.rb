class SubjectsIntroController < ApplicationController

  before_filter :authorize

  def show
    @subject = Subject.find(params[:subject_id].gsub('S', ''))
    render 'subjects/intro'
  end

  def update
    @subject = Subject.find(params[:subject_id].gsub('S', ''))

    @subject.wellcome_intro = params[:subject][:wellcome_intro]
    @subject.wellcome_intro_updated_by = current_user

    if @subject.save
      redirect_to subject_path(@subject)
    else
      redirect_to person_intro_path(@subject)
    end

  end

end
