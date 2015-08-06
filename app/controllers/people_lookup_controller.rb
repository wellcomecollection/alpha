class PeopleLookupController < ApplicationController

  def index
    redirect_to "/people/#{params[:name]}"
  end

  def show
    @people = people_with_names_starting(params[:id])
    respond_to do |format|
      format.html do
        if (@people.length == 1)
          redirect_to person_path(@people.first)
        else
          render :show
        end
      end
      format.json { render json: @people.collect(&:to_api) }
    end
  end

  private

  def people_with_names_starting(name)
    Person
      .select(:id, :name, :wikipedia_images, :records_count)
      .where(["LOWER(name) LIKE ? ", name.downcase + '%'])
      .order('records_count desc')
      .limit(50)
  end

end
