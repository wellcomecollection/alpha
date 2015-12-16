class PeopleEditorialController < ApplicationController

  before_filter :authorize

  def show
    @person = Person.find(params[:person_id].gsub('P', ''))
    render 'people/editorial'
  end

  def update
    @person = Person.find(params[:person_id].gsub('P', ''))

    @person.editorial_title = params[:person][:editorial_title]
    @person.editorial_content = params[:person][:editorial_content]
    @person.editorial_updated_by = current_user

    if @person.save
      redirect_to person_path(@person)
    else
      redirect_to editorial_person_path(@person)
    end

  end

end
