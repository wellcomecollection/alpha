class CollectionTypesController < ApplicationController

  def show
    @collection = Collection.find_by(slug: params[:collection_id])
    @type = Type.find_by(id: params[:id].gsub('T',''))


    @records = @collection.records
      .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .joins(:record_types)
      .where(record_types: {type_id: @type.id})
      .order(:digitized).reverse_order
      .limit(100)
  end

  def index

    @collection = Collection.find_by(slug: params[:collection_id])

    @types = @collection.collection_memberships
      .joins(record_types: :type)
      .select(['types.id', 'types.name', 'count(record_types.id) as records_within_type_and_collection_count'])
      .group('types.id')
      .order('records_within_type_and_collection_count').reverse_order
      .limit(500)
  end

end
