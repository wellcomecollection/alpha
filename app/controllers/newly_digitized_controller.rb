class NewlyDigitizedController < ApplicationController

  def show

    @records_digitized_in_past_week_count = Record
      .where(digitized_at: 7.days.ago..Time.now)
      .count

    @top_subjects = Subject
      .select('subjects.id, subjects.label, count(taggings.record_id) as records_digitized_recently_count')
      .joins(taggings: :record)
      .where(records: {digitized_at: 7.days.ago..Time.now})
      .order('records_digitized_recently_count desc')
      .group('subjects.id, subjects.label')
      .limit(20)

    @top_authors = Person
      .select('people.id, people.name, count(creators.record_id) as records_digitized_recently_count')
      .joins(creators: :record)
      .where(records: {digitized_at: 7.days.ago..Time.now})
      .order('records_digitized_recently_count desc')
      .group('people.id, people.name')
      .limit(20)

    @records = Record.select(:id, :identifier, :title, :cover_image_uris, :pdf_thumbnail_url, :digitized_at)
      .where.not(digitized_at: nil)
      .where(access_conditions: 'Open')
      .order(:digitized_at).reverse_order
      .limit(200)
  end

end
