class Subject < ActiveRecord::Base

  has_many :taggings, dependent: :destroy
  has_many :records, through: :taggings

  belongs_to :wellcome_intro_updated_by, class_name: 'User'

  before_save :set_wellcome_intro_updated_at, if: :wellcome_intro_changed?
  before_save :set_wellcome_intro_to_null, if: "wellcome_intro.blank?"

  scope :highlighted, -> { where(highlighted: true) }

  def to_param
    "S#{id}"
  end

  def to_api
    {id: to_param, label: label, records_count: records_count}
  end

  def to_elasticsearch

    {
      id: to_param,
      label: label,
      all_labels: all_labels,
      records_count: records_count,
      identifiers: identifiers
    }

  end

  def update_records_count!
    self.records_count = records.count
    save!
  end

  def update_digitized_records_count!
    self.digitized_records_count = records.digitized.count
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

  private

  def set_wellcome_intro_updated_at
    write_attribute(:wellcome_intro_updated_at, Time.now)
  end

  def set_wellcome_intro_to_null
    write_attribute(:wellcome_intro, nil)
  end

end
