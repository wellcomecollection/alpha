class SetRightsOnRecordJob < ActiveJob::Base
  queue_as :default

  def perform(record)
    record.rights = record.package.dig('assetSequences', 0, 'extensions', 'dzLicenseCode')
    record.save!
  end

end
