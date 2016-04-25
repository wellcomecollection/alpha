class TypesController < ApplicationController

  def index
    @types = Type.order('records_count desc')
  end

  def show
    @type = Type.find(params[:id].gsub('T',''))

    @records = @type.records.select(:identifier, :title, :pdf_thumbnail_url,
      :cover_image_uris).order('digitized desc', :title).limit(100)
  end

end
