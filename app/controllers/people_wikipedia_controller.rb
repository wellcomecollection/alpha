class PeopleWikipediaController < ApplicationController

  before_filter :authorize


  def update
    @person = Person.find(params[:person_id].gsub('P', ''))

    @person.update_from_wikipedia!

    redirect_to person_intro_path(@person)
  end

end
