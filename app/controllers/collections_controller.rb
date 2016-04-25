class CollectionsController < ApplicationController

  def index
    @collections = Collection.all
  end

  def show
    @collection = Collection.find(params[:id])
    @records = @collection.records.limit(100)
  end

end
