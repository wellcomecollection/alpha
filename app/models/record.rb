class Record < ActiveRecord::Base

  has_many :creators
  has_many :people, through: :creators

  has_many :taggings
  has_many :subjects, through: :taggings

  scope :digitized, -> { where(digitized: true) }

  before_save :set_cover_image_uris, :set_pdf_thumbnail_url
  before_save :set_digitized
  before_save :set_access_conditions
  before_save :set_year

  def to_param
    identifier
  end

  def summary
    metadata['520'].to_a.first.to_h['a']
  end

  def about
    metadata['545'].to_a.first.to_h['a']
  end

  def to_elasticsearch

    {
      id: to_param,
      title: title,
      digitized: digitized,
      year: year,
      pdf_thumbnail_url: pdf_thumbnail_url,
      cover_image_uris: cover_image_uris,
      archives_ref: archives_ref,
      subject_ids: taggings.pluck(:subject_id),
      person_ids: creators.pluck(:person_id)
    }

  end

  def archives_tree

    ref = archives_ref

    tree = []

    while !ref.blank?
      ref = ref.gsub(/\/?[^\/]+\z/, '')
      unless ref.blank?
        tree << ref
      end
    end

    Record.where(archives_ref: tree.reverse.compact)
  end

  def collection
    if metadata['244']
      "Archives"
    elsif metadata['001'].to_a.first.to_s.end_with? 'i'
      "Art"
    else
      nil
    end
  end

  def pdf_file
    file_path = (package || {})
      .fetch('assetSequences', [])
      .collect {|x| x.fetch('assets', []).collect{|y| y['fileUri']} }
      .flatten
      .keep_if {|file| file =~ /\.pdf\z/ }
      .first

    file_path ? "http://wellcomelibrary.org#{file_path}" : nil
  end

  def image_url(width = 150, height = 300)
    pdf_thumbnail_url || cover_image_url(width, height) || image_urls(width, height).first
  end

  def cover_image_url(width = 800, height = 800)

    if pdf_thumbnail_url
      pdf_thumbnail_url
    elsif cover_image_uris
      "#{cover_image_uris.first}/full/!#{width},#{height}/0/default.jpg"
    else
      nil
    end
  end

  def image_urls(width = 800, height = 800)
    image_service_urls.map { |url| "#{url}/full/!#{width},#{height}/0/default.jpg" }
  end

  def image_service_urls
    image_assets.map { |asset| "http://wellcomelibrary.org/iiif-img/#{identifier}-#{asset.fetch(:sequence_index)}/#{asset.fetch(:identifier)}" }
  end

  def publishers
    publishers = metadata.fetch('260', []).collect {|x| x['b'].to_s.gsub(/\,\z/, '').gsub(/[\[\]]/, '').strip}.reject(&:blank?)
    publishers.length > 0 ? publishers : nil
  end

  # Remove trailing slash. Artefact of MARC?
  def title
    read_attribute(:title).gsub(/\/\z/, '').strip
  end

  def update_creators_count!
    self.creators_count = creators.count
    save!
  end


  private

  # This copies the 'access conditions' from the image package
  # to a separate column, for speedier querying.
  def set_access_conditions

    if package
      access_conditions = package['assetSequences']
      .to_a.first.to_h['rootSection'].to_h['extensions'].to_h['accessCondition']
    else
      access_conditions = nil
    end

    write_attribute(:access_conditions, access_conditions)
  end

  def set_year
    write_attribute(:year, metadata['008'].first[7..10])
  end

  def set_digitized
    digitized = !(package.nil? || package == {})
    write_attribute(:digitized, digitized)
    return true
  end

  def set_cover_image_uris

    if image_service_urls.length > 0
      cover_image_uris = [image_service_urls.first]
    else
      cover_image_uris = nil
    end

    write_attribute(:cover_image_uris, cover_image_uris)
  end

  def set_pdf_thumbnail_url
    file_path = (package || {})
      .fetch('assetSequences', [])
      .collect {|x| x.fetch('assets', []) }
      .flatten
      .keep_if {|x| x['fileUri'].to_s =~ /\.pdf\z/ }
      .collect {|x| x['thumbnailPath'] }
      .first

    pdf_thumbnail_url = file_path ? "http://wellcomelibrary.org#{file_path}" : nil

    write_attribute(:pdf_thumbnail_url, pdf_thumbnail_url)
  end

  def image_asset_sequences
    # this will probably only return the first sequence, but that’s fine for now
    (package || {}).fetch('assetSequences', []).select { |sequence| sequence.has_key?('index') }
  end

  def image_assets
    image_asset_sequences.flat_map do |sequence|
      index = sequence.fetch('index')
      sequence.fetch('assets', []).map do |asset|
        { sequence_index: index, identifier: asset.fetch('identifier') }
      end
    end
  end

end
