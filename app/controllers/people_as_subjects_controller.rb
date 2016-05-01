class PeopleAsSubjectsController < ApplicationController

  def show
    id = params[:id].gsub('P','')

    @person = Person.find(id)

    @things = @person
      .records_as_subject
      .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .order('digitized desc').limit(500)

  end

end
