class UpdateTaggingsFromMetadataJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    name_regex = /\A([^\,]+)\,\s?([^\,]+)\z/

    (
      record.metadata.fetch('650', []) +
      record.metadata.fetch('651', []) +
      record.metadata.fetch('610', [])
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

          tagging = record.taggings.new(subject: subject, label: field['a'])

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

          tagging = record.taggings.new(subject: subject, label: subject_label)

          begin
            tagging.save!
          rescue ActiveRecord::RecordNotUnique
          end

        end

      end

    end

  end
end
