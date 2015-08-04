class Record < ActiveRecord::Base

  has_many :creators
  has_many :people, through: :creators

  def to_param
    identifier
  end

  def image_service_urls
    image_assets.map { |asset| "http://wellcomelibrary.org/iiif-img/#{identifier}-#{asset.fetch(:sequence_index)}/#{asset.fetch(:identifier)}" }
  end

  private

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
