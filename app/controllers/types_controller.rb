class TypesController < ApplicationController

  def index
    @types = Type.order('records_count desc')
  end

  def show
    @type = Type.find(params[:id].gsub('T',''))

    @records = @type.records.select(:identifier, :title, :pdf_thumbnail_url,
      :cover_image_uris).order('digitized desc', :title).limit(100)

    @subjects = Subject
      .select(['subjects.id', :label])
      .select('count(taggings.record_id) as records_in_subject_count')
      .joins(taggings: [:record_types])
      .where(record_types: {type_id: @type.id})
      .group('subjects.id')
      .order('records_in_subject_count desc')
      .limit(20)


  end

end
