class CollectionPeopleController < ApplicationController

  def show
    @collection = Collection.find_by(slug: params[:collection_id])
    @person = Person.find_by(id: params[:id].gsub('P',''))


    @records = @collection.records
      .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .joins(:creators)
      .where(creators: {person_id: @person.id})
      .order(:digitized).reverse_order
      .limit(100)
  end

  def index

    @collection = Collection.find_by(slug: params[:collection_id])

    @people = @collection.collection_memberships
      .joins(creators: :person)
      .select(['people.id', 'people.name', 'count(creators.id) as records_within_person_and_collection_count'])
      .group('people.id')
      .order('records_within_person_and_collection_count').reverse_order
      .limit(500)
  end

end
