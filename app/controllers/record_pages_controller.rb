class RecordPagesController < ApplicationController

  def show
    @page = params[:id].to_i
    @thing = Record.find_by!(identifier: params[:thing_id])

    @image = @thing.image_service_urls[@page - 1]

    render 'things/page'
  end

  def index

    @thing = Record.find_by!(identifier: params[:thing_id])


    render 'things/pages'
  end

end
