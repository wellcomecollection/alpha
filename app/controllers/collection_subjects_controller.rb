class CollectionSubjectsController < ApplicationController

  def show
    @collection = Collection.find_by(slug: params[:collection_id])
    @subject = Subject.find_by(id: params[:id].gsub('S',''))


    @records = @collection.records
      .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
      .joins(:taggings)
      .where(taggings: {subject_id: @subject.id})
      .order(:digitized).reverse_order
      .limit(100)
  end

  def index

    @collection = Collection.find_by(slug: params[:collection_id])

    @subjects = @collection.collection_memberships
      .joins(taggings: :subject)
      .select(['subjects.id', 'subjects.label', 'count(taggings.id) as records_within_subject_and_collection_count'])
      .group('subjects.id')
      .order('records_within_subject_and_collection_count').reverse_order
      .limit(500)
  end

end
