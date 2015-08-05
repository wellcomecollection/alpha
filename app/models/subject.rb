class Subject < ActiveRecord::Base

  has_many :taggings, dependent: :destroy
  has_many :records, through: :taggings

  def to_param
    "S#{id}"
  end

  def update_records_count!
    self.records_count = records.count
    save!
  end

  def reverse_label_if_contains_single_comma!

    regex = /\A([^\,]+)\,\s([^\,]+)\z/

    match = regex.match(label)

    if match

      self.all_labels << label
      self.label = "#{match[2]} #{match[1]}"
      save!

    end

  end

  def copy_mesh_identifier!
    if identifier
      identifiers['mesh'] ||= identifier
      save!
    end
  end

end
