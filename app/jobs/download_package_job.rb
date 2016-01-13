require 'open-uri'

class DownloadPackageJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    package_url = "http://wellcomelibrary.org/package/#{record.identifier}/"

    begin

      response = open(package_url)
      status = response.status.first

      record.update_attributes(package: JSON.parse(response.read))

    rescue OpenURI::HTTPError => e

      error_code = e.io.status.first

      if error_code == '500'

        record.update_attributes(package: {})

      else
        raise "Error #{error_code} when fetching #{package_url}"
      end

    end

  end

end
