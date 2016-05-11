class Collection < ActiveRecord::Base

  has_many :collection_memberships, dependent: :destroy
  has_many :records, through: :collection_memberships

  scope :highlighted, -> { where(highlighted: true) }

  def to_param
    slug
  end

  def update_digitized_records_count!
    update_attribute(:digitized_records_count, records.digitized.count)
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

end
