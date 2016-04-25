class CollectionsController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @collections = Collection.order(:records_count).reverse_order
  end

  def show
    @collection = Collection.find(params[:id])
    @records = @collection.records.order(:title).limit(500)
  end

  def edit
    @collection = Collection.find(params[:id])
  end

  def update
    @collection = Collection.find(params[:id])
    @collection.update_attributes(collection_params)
    redirect_to @collection
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description)
  end

end
