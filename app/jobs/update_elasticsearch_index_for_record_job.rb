class UpdateElasticsearchIndexForRecordJob < ActiveJob::Base
  queue_as :default

  def perform(record)

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL')

    client.index index: 'records', type: 'record', body: record.to_elasticsearch, id: record.to_param

  end

end
