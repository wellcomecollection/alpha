class PeopleController < ApplicationController

  def index
    @top_people = Person.order(:records_count).reverse_order.limit(200)
  end

  def show

    id = params[:id].gsub("P", "")

    @person = Person.find(id)

    @things = @person.records.select(:identifier, :title).limit(100)
  end

end
