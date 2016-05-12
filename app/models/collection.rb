class Collection < ActiveRecord::Base

  has_many :collection_memberships, dependent: :destroy
  has_many :records, through: :collection_memberships

  belongs_to :editorial_updated_by, class_name: 'User'


  before_save :set_editorial_updated_at, :set_editorial_to_null_if_both_blank

  scope :highlighted, -> { where(highlighted: true) }

  def to_param
    slug
  end

  def update_digitized_records_count!
    update_attribute(:digitized_records_count, records.digitized.count)
  end

  def editorial
    editorial_title ? true : false
  end

  def to_elasticsearch
    {
      name: name,
      slug: slug,
      description: description,
      all_names: [name],
      records_count: records_count,
      digitized_records_count: digitized_records_count,
      from_year: from_year,
      to_year: to_year
    }
  end

  def update_from_and_to_years!

    years = records
      .pluck('distinct year')
      .select {|year| year =~ /\d{4}/ && year < (Time.now.year + 1).to_s && year != "0000"}.sort_by {|year| year }


    if years.length > 0

      from_year = years.first
      to_year = years.last

    end

    update_columns(from_year: from_year, to_year: to_year)

  end

  private

  def set_editorial_to_null_if_both_blank
    if editorial_title.blank? && editorial_content.blank?
      write_attribute(:editorial_title, nil)
      write_attribute(:editorial_content, nil)
    end
  end

  def set_editorial_updated_at
    if editorial_title_changed? || editorial_content_changed?
      write_attribute(:editorial_updated_at, Time.now)
    end
  end

end
