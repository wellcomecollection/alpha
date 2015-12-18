require 'open-uri'

class Record < ActiveRecord::Base

  has_many :creators
  has_many :people, through: :creators

  has_many :taggings
  has_many :subjects, through: :taggings

  scope :digitized, -> { where(digitized: true) }

  before_save :set_cover_image_uris, :set_pdf_thumbnail_url
  before_save :set_digitized
  before_save :set_access_conditions

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
      archives_ref: archives_ref
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
      "Iconographic"
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

  def update_taggings_from_metadata!

    name_regex = /\A([^\,]+)\,\s?([^\,]+)\z/

    (
      metadata.fetch('650', []) +
      metadata.fetch('651', []) +
      metadata.fetch('610', [])
    ).each do |field|

      label = field['a'].to_s
      subject_authority_id = field['0']
      subject_type = nil

      if ind2 = field['ind2']

        case ind2
        when '0'
          subject_type = 'loc'
        when '2'
          subject_type = 'mesh'
          subject_authority_id = subject_authority_id.to_s[/\A(\D\d+)/, 1]
        end

        if subject_type == 'mesh'

          # reverse label if it contains a single comma
          match = /\A([^\,]+)\,\s([^\,]+)\z/.match(label)
          if match
            label = "#{match[2]} #{match[1]}".strip
          end

          label = label.gsub(/\.\z/, '')    # remove any trailing full stop
          label = label.gsub('<p>', '')     # remove any pargraph tags
          label = label.strip

          if subject_authority_id.blank?

            subject = Subject.where(["LOWER(label) = ?", label.downcase]).take ||
              Subject.new(label: label, all_labels: [label], identifiers: {})

          else
            subject = Subject.where(["identifiers->? = ?", subject_type, subject_authority_id]).take
          end



        elsif subject_type == 'loc'

          # First try and find the subject using the ID
          if subject_authority_id
            subject = Subject.where(["identifiers->'loc' = ?", subject_authority_id]).take
          end

          # Otherwise resort to string matching
          if subject.nil?

            comma_regex = /\A([^\,]+)\,\s([^\,]+)\z/
            brackets_regex = /\s\(([^)]+)\)\z/

            label = label.gsub(/\.\z/, '')    # remove any trailing full stop
            label = label.gsub('<p>', '')     # remove any pargraph tags
            label = label.strip

            if brackets_regex.match(label)

              bracket = label[brackets_regex, 1]
              pre_bracket = label.gsub(brackets_regex, '')

              if comma_regex.match(pre_bracket)
                label = "#{pre_bracket[comma_regex, 2]} #{pre_bracket[comma_regex, 1]} (#{bracket})"
              end

            else

              if comma_regex.match(label)
                label = "#{label[comma_regex, 2]} #{label[comma_regex,1]}".strip
              end

            end

            subject = Subject.where(["LOWER(label) = ?", label.downcase]).take

            if subject.nil?
              subject = Subject.new(label: label, all_labels: [label])
            end

          end

          if subject && subject_authority_id
            subject.identifiers ||= {}
            subject.identifiers['loc'] = subject_authority_id
          end

        end


        if subject

          subject.all_labels << field['a']
          subject.all_labels = subject.all_labels.uniq

          subject.save!

          tagging = taggings.new(subject: subject, label: field['a'])

          begin
            tagging.save!
          rescue ActiveRecord::RecordNotUnique
          end

        end

        # Is there a qualifying term?
        if subject_type == 'mesh' && field['x']

          subject_authority_id = field['0']

          subject_label =
            field['a'].gsub(/\.\z/, '').strip +
            " (" +
            field['x'].gsub(/\.\z/, '').strip +
            ")"

          all_labels = [subject_label, "#{field['a']}, #{field['x']}"]

          if subject_label.match(name_regex)
            subject_label = "#{subject_label[name_regex,2]} #{subject_label[name_regex,1]}"

            all_labels << subject_label
          end

          subject = Subject
            .where(["identifiers->? = ?", subject_type, subject_authority_id]).take ||
            Subject.new(identifiers: {subject_type => subject_authority_id})

          subject.label ||= subject_label
          subject.all_labels = (subject.all_labels.to_a + all_labels).uniq
          subject.save!

          tagging = taggings.new(subject: subject, label: subject_label)

          begin
            tagging.save!
          rescue ActiveRecord::RecordNotUnique
          end

        end

      end

    end

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

  def set_digitized
    digitized = !(package.nil? || package == {})
    write_attribute(:digitized, digitized)
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

  def self.download_packages!

    loop do

      record_ids = where("metadata->'759'->0->>'a' LIKE '%dig%' AND NOT(metadata ? '856')")
        .where(package: nil).limit(200).pluck(:identifier)

      if record_ids.length == 0
        puts "Done"
        break
      end

      record_ids.each do |record_id|

        package_url = "http://wellcomelibrary.org/package/#{record_id}/"

        begin

          response = open(package_url)
          status = response.status.first

          if status == '200'

            Record.find_by(identifier: record_id).update_attributes(package: JSON.parse(response.read))
          else
            raise "#{record_id}: #{status}"
          end

        rescue OpenURI::HTTPError => e

          error_code = e.io.status.first

          if error_code == '500'

            Record.find_by(identifier: record_id).update_attributes(package: {})

          else
            raise "Error #{error_code} when fetching #{package_url}"
          end
        end

      end

    end

  end

end
