class PeopleIntroController < ApplicationController

  before_filter :authorize

  def show
    @person = Person.find(params[:person_id].gsub('P', ''))
    render 'people/intro'
  end

  def update
    @person = Person.find(params[:person_id].gsub('P', ''))

    @person.wellcome_intro = params[:person][:wellcome_intro]
    @person.wellcome_intro_updated_by = current_user

    if @person.save
      redirect_to person_path(@person)
    else
      redirect_to editorial_person_path(@person)
    end

  end

end
