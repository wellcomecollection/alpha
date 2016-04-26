class CollectionsController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @collections = Collection.order(:records_count).reverse_order
  end

  def show
    @collection = Collection.find_by_slug!(params[:id])
    @records = @collection.records.order('digitized desc', :title).limit(500)

    @types = RecordType
      .select('types.*')
      .select('count(record_types.record_id) as records_in_type_count')
      .joins(:type, :collection_memberships)
      .where(collection_memberships: {collection_id: @collection.id})
      .group('types.id')
      .order('records_in_type_count desc')
      .limit(10)

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
