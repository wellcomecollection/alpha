class PeopleController < ApplicationController

  def index
    @top_people = Person
      .where("array_length(wikipedia_images, 1) > 0")
      .where('records_count > 4')
      .order('random()').limit(200)
  end

  def show

    id = params[:id].gsub("P", "")

    @person = Person.find(id)

    @digitized_count = @person.records.where(digitized: true).count

    @co_authors = Creator
      .joins(:person)
      .select("people.*, count(creators.id) as count")
      .where(["creators.record_id IN (select creators.record_id from creators where creators.person_id = ?)", @person.id])
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
      .where(["records.id IN (select creators.record_id from creators where creators.person_id = ?)", @person.id])
      .where.not(year: nil)
      .group('year')
      .order('year')
      .count

    @top_subjects_written_about = Subject
      .joins(:taggings)
      .select("subjects.*, count(taggings.id) as count")
      .where(["taggings.record_id IN (select creators.record_id from creators where creators.person_id = ?)", @person.id])
      .group('subjects.id')
      .order('count desc')
      .limit(18)

    @things = @person.records.select(:identifier, :title, :package)
      .order('digitized desc')
      .limit(100)
  end

end
