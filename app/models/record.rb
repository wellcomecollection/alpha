class Record < ActiveRecord::Base

  has_many :creators
  has_many :people, through: :creators

  has_many :taggings
  has_many :subjects, through: :taggings

  def to_param
    identifier
  end

  def image_urls(size: 800)
    image_service_urls.map { |url| "#{url}/full/!#{size},#{size}/0/default.jpg" }
  end

  def image_service_urls
    image_assets.map { |asset| "http://wellcomelibrary.org/iiif-img/#{identifier}-#{asset.fetch(:sequence_index)}/#{asset.fetch(:identifier)}" }
  end

  def update_taggings_from_metadata!

    name_regex = /\A([^\,]+)\,\s?([^\,]+)\z/

    metadata.fetch('650', []) +
    metadata.fetch('651', []) +
    metadata.fetch('610', []).each do |field|

      label = field['a'].to_s
      subject_authority_id = field['0']
      subject_type = nil

      if ind2 = field['ind2']

        case ind2
        when '0'
          subject_type = 'loc'
        # when '2'
        #   subject_type = 'mesh'
        #   subject_authority_id = subject_authority_id[/\A(\D\d+)/, 1]
        end

        if subject_type == 'mesh'

          subject = Subject.where(["identifiers->? = ?", subject_type, subject_authority_id]).take

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
