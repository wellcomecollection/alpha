class PeopleWikipediaController < ApplicationController

  before_filter :authorize


  def update
    @person = Person.find(params[:person_id].gsub('P', ''))

    UpdatePersonFromWikipediaJob.perform_later(@person)

    redirect_to person_intro_path(@person)
  end

end
