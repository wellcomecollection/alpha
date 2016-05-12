class CollectionsController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @collections = Collection.not_hidden.order(:records_count).reverse_order

    @highlighted_collections = @collections
      .select {|collection| collection.highlighted == true }.shuffle.take(4)

    @subjects = Subject.find_by_sql("select collections.id as collection_id, counts.subject_id as id, subjects.label from collections, lateral (
        select taggings.subject_id as subject_id, count(taggings.record_id) as records_count from taggings inner join collection_memberships on collection_memberships.record_id = taggings.record_id where collection_memberships.collection_id = collections.id group by taggings.subject_id order by records_count desc limit 6

      ) counts inner join subjects on counts.subject_id = subjects.id")


    @types = Type.find_by_sql("select collections.id as collection_id, counts.type_id as id, types.name from collections, lateral (
        select record_types.type_id as type_id, count(record_types.record_id) as records_count from record_types inner join collection_memberships on collection_memberships.record_id = record_types.record_id where collection_memberships.collection_id = collections.id group by record_types.type_id order by records_count desc limit 6

      ) counts inner join types on counts.type_id = types.id")


    @people = Person.find_by_sql("select collections.id as collection_id, counts.person_id as id, people.name, people.wikipedia_images, counts.records_count from collections, lateral (
        select creators.person_id as person_id, count(creators.record_id) as records_count from creators inner join collection_memberships on collection_memberships.record_id = creators.record_id where collection_memberships.collection_id = collections.id group by creators.person_id order by records_count desc limit 6

      ) counts inner join people on counts.person_id = people.id")

    @records_ids_per_collection = Record.find_by_sql("select collections.id as collection_id, records.record_id from collections, lateral (
      select record_id from collection_memberships where collection_memberships.collection_id = collections.id limit 5
      ) records")


    @records = Record
      .select(:id, :identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .find(@records_ids_per_collection.collect {|r| r['record_id']} )


    @people_counts = CollectionMembership
      .select('collection_id', "count(distinct creators.person_id) as count")
      .joins(:creators)
      .group(:collection_id)
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
      .limit(20)

    @people = Creator
      .select('people.*')
      .select('count(creators.record_id) as records_by_person_count')
      .joins(:person, :collection_memberships)
      .where(collection_memberships: {collection_id: @collection.id})
      .group('people.id')
      .order('records_by_person_count desc')
      .limit(20)

    @subjects = Subject
      .select(['subjects.id', :label])
      .select('count(taggings.record_id) as records_in_subject_count')
      .joins(taggings: [:collection_memberships])
      .where(collection_memberships: {collection_id: @collection.id})
      .group('subjects.id')
      .order('records_in_subject_count desc')
      .limit(20)

  end

  def new
    @collection = Collection.new
    @collection.name = params[:name]
    @collection.slug = params[:slug]
    @collection.description = params[:description]
    @collection.editorial_title = params[:editorial_title]
    @collection.editorial_content = params[:editorial_content]

  end

  def edit
    @collection = Collection.find_by_slug!(params[:id])
    @record_identifiers = @collection
      .collection_memberships
      .joins(:record)
      .pluck("records.identifier")
  end

  def all
    @collections = Collection.select(:slug, :name, :hidden).order(:name)
  end

  def editorial
    @collection = Collection.find_by_slug!(params[:collection_id])
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.slug = params[:collection][:slug]

    if !@collection.editorial_title.blank? || !@collection.editorial_content.blank?
      @collection.editorial_updated_by = current_user
    end

    if @collection.save

      add_record_numbers(params[:record_numbers].to_s.scan(/b\d+[\dx]/))

      redirect_to collection_path(@collection)
    else
      redirect_to new_collection_path(params[:collection])
    end

  end

  def status
    @collection = Collection.find_by_slug!(params[:collection_id])

    @collection.hidden = params[:collection][:hidden]
    @collection.save!

    redirect_to all_collections_path

  end

  def update
    @collection = Collection.find_by_slug!(params[:id])
    @collection.attributes = collection_params

    if @collection.editorial_title_changed? || @collection.editorial_content_changed?
      @collection.editorial_updated_by = current_user
    end

    @collection.save!

    record_identifiers = params[:record_numbers].to_s.scan(/b\d+[\dx]/)

    existing_record_identifiers = @collection
      .collection_memberships
      .joins(:record)
      .pluck("records.identifier")

    add_record_numbers(record_identifiers - existing_record_identifiers)
    remove_record_numbers(existing_record_identifiers - record_identifiers)

    redirect_to @collection
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :highlighted, :editorial_title, :editorial_content)
  end

  def remove_record_numbers(record_identifiers)

    if record_identifiers.length > 0

      record_ids = Record.where(identifier: record_identifiers).pluck(:id)

      @collection.collection_memberships.where(record_id: record_ids).destroy_all

    end

  end

  def add_record_numbers(record_identifiers)

    if record_identifiers.length > 0

      record_ids = Record.where(identifier: record_identifiers).pluck(:id)

      record_ids.each do |record_id|

        begin
          @collection.collection_memberships << CollectionMembership.new(record_id: record_id)
        rescue ActiveRecord::RecordNotUnique
          # Ignore duplicates
        end

      end

    end
  end


end
