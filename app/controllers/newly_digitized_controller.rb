class NewlyDigitizedController < ApplicationController

  def show
    @records = Record.select(:id, :identifier, :title, :cover_image_uris, :pdf_thumbnail_url)
      .where.not(digitized_at: nil)
      .order(:digitized_at).reverse_order
      .limit(200)
  end

end
