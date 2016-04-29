class RecordPagesController < ApplicationController

  def show
    @page = params[:id].to_i
    @thing = Record.find_by!(identifier: params[:thing_id])

    @image = @thing.image_service_urls[@page]

    render 'things/page'
  end

end
