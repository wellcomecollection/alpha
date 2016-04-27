class CollectionsController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @collections = Collection.order(:records_count).reverse_order

    @subjects = Subject.find_by_sql("select collections.id as collection_id, counts.subject_id as id, subjects.label from collections, lateral (
        select taggings.subject_id as subject_id, count(taggings.record_id) as records_count from taggings inner join collection_memberships on collection_memberships.record_id = taggings.record_id where collection_memberships.collection_id = collections.id group by taggings.subject_id order by records_count desc limit 6

      ) counts inner join subjects on counts.subject_id = subjects.id")


    @types = Type.find_by_sql("select collections.id as collection_id, counts.type_id as id, types.name from collections, lateral (
        select record_types.type_id as type_id, count(record_types.record_id) as records_count from record_types inner join collection_memberships on collection_memberships.record_id = record_types.record_id where collection_memberships.collection_id = collections.id group by record_types.type_id order by records_count desc limit 6

      ) counts inner join types on counts.type_id = types.id")


    @people = Person.find_by_sql("select collections.id as collection_id, counts.person_id as id, people.name, people.wikipedia_images, counts.records_count from collections, lateral (
        select creators.person_id as person_id, count(creators.record_id) as records_count from creators inner join collection_memberships on collection_memberships.record_id = creators.record_id where collection_memberships.collection_id = collections.id group by creators.person_id order by records_count desc limit 6

      ) counts inner join people on counts.person_id = people.id")

    @records = Record.find_by_sql("select collections.id as collection_id, records.* from collections, lateral (
      select identifier, title, pdf_thumbnail_url, cover_image_uris from records inner join collection_memberships on collection_memberships.record_id = records.id where collection_memberships.collection_id = collections.id order by digitized desc limit 6
      ) records")


    @people_counts = CollectionMembership.joins(:creators).group(:collection_id).count
  end

  def show
    @collection = Collection.find_by_slug!(params[:id])
    @records = @collection.records
      .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .order('digitized desc', :title).limit(500)

    @types = RecordType
      .select('types.*')
      .select('count(record_types.record_id) as records_in_type_count')
      .joins(:type, :collection_memberships)
      .where(collection_memberships: {collection_id: @collection.id})
      .group('types.id')
      .order('records_in_type_count desc')
      .limit(100)

    @people = Creator
      .select('people.*')
      .select('count(creators.record_id) as records_by_person_count')
      .joins(:person, :collection_memberships)
      .where(collection_memberships: {collection_id: @collection.id})
      .group('people.id')
      .order('records_by_person_count desc')
      .limit(100)

    @subjects = Subject
      .select(['subjects.id', :label])
      .select('count(taggings.record_id) as records_in_subject_count')
      .joins(taggings: [:collection_memberships])
      .where(collection_memberships: {collection_id: @collection.id})
      .group('subjects.id')
      .order('records_in_subject_count desc')
      .limit(20)

  end

  def edit
    @collection = Collection.find_by_slug!(params[:id])
  end

  def update
    @collection = Collection.find_by_slug!(params[:id])
    @collection.update_attributes(collection_params)
    redirect_to @collection
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description)
  end

end
