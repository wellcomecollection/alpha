class CollectionsController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @collections = Collection.all
  end

  def show
    @collection = Collection.find(params[:id])
    @records = @collection.records.limit(100)
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
