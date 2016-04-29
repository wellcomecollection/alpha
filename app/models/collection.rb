class Collection < ActiveRecord::Base

  has_many :collection_memberships, dependent: :destroy
  has_many :records, through: :collection_memberships

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
      digitized_records_count: digitized_records_count
    }
  end

end
