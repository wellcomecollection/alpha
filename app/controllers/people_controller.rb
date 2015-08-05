class PeopleController < ApplicationController

  def index
    @top_people = Person.order(:records_count).reverse_order.limit(200)
  end

  def show

    id = params[:id].gsub("P", "")

    @person = Person.find(id)

    thing_ids = @person.records.pluck(:id)

    @digitized_count = @person.records.where(digitized: true).count

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

    @publication_years = Record
      .select('year')
      .where(id: thing_ids)
      .where.not(year: nil)
      .group('year')
      .order('year')
      .count

    @top_subjects_written_about = Subject
      .joins(:taggings)
      .select("subjects.*, count(taggings.id) as count")
      .where(taggings: {record_id: thing_ids})
      .group('subjects.id')
      .order('count desc')
      .limit(10)

    @things = @person.records.select(:identifier, :title, :package)
      .order('digitized desc')
      .limit(100)
  end

end
