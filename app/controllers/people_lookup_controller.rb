class PeopleLookupController < ApplicationController

  def index
    @name = params[:name].to_s
    limit = params[:limit] || 20

    @people = people_with_names_starting(@name, limit)


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

  def show
    @name = params[:id]
    @people = people_with_names_starting(@name)
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

  def people_with_names_starting(name, limit = 50)
    Person
      .select(:id, :name, :wikipedia_images, :records_count)
      .where(["LOWER(name) LIKE ? ", name.downcase + '%'])
      .order('records_count desc')
      .limit(limit)
  end

end
