class CollectionsEditorialController < ApplicationController

  before_filter :authorize

  def show
    @collection = Collection.find_by_slug!(params[:collection_id])
    render 'collections/editorial'
  end

  def update
    @collection = Collection.find_by_slug!(params[:collection_id])
    @collection.attributes = collection_params

    if @collection.editorial_title_changed? || @collection.editorial_content_changed?
      @collection.editorial_updated_by = current_user
    end

    @collection.save!

    redirect_to @collection
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :highlighted, :editorial_title, :editorial_content)
  end

end
