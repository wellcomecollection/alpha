class PeopleController < ApplicationController

  def index
    @top_people = Person.order(:records_count).reverse_order.limit(200)
  end

  def show

    id = params[:id].gsub("P", "")

    @person = Person.find(id)

    thing_ids = @person.records.pluck(:id)

    @co_authors = Creator
      .joins(:person)
      .select("people.*, count(creators.id) as count")
      .where(record_id: thing_ids)
      .where.not(person_id: @person.id)
      .group('people.id')
      .order('count desc')
      .limit(10)

    if @person.born_in

      born_in_range = (@person.born_in - 4)..(@person.born_in + 4)

      @contemporaries = Person
        .where(born_in: born_in_range)
        .where.not(id: @person.id)
        .order('records_count desc')
        .limit(10)

    end

    @things = @person.records.select(:identifier, :title).limit(100)
  end

end
