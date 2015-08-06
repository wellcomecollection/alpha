require 'elasticsearch'

namespace :elasticsearch do


  desc 'Ingest people into elasticsearch'
  task people: :environment do

    logging = false
    index_name = 'people'

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: logging

    client.indices.delete index: index_name

    client.indices.create index: index_name,
      body: {
        mappings: {
          record: {
            properties: {
              name: {
                type: 'string',
                analyzer: :english,
                fields: {
                  raw: {type: 'string', index: :not_analyzed }
                }
              },
              id: {type: 'string', index: :not_analyzed},
              records_count: {type: 'integer'},
              identifiers: {type: 'object', index: :not_analyzed },
              born_in: {type: 'integer'},
              died_in: {type: 'integer'},
              wikipedia_intro_paragraph: {type: 'string', analyzer: :english}
            }
          }
        }
      }

    total = 0


    puts "Importing people into Elasticsearch…"

    Person.find_in_batches do |records|
      puts "Importing records #{total + 1}–#{total + records.length}…"
      total = total + records.length

      body =
        records.map { |record|

          {
            index: {
              _index: index_name,
              _type:  'record',
              _id:    record.to_param,
              data:   record.to_elasticsearch
            }
          }
        }

      client.bulk body: body
    end

    puts "Finished importing #{total} records"

  end

  desc 'Ingest subjects into elasticsearch'
  task subjects: :environment do

    logging = false
    index_name = 'subjects'

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: logging

    client.indices.delete index: index_name

    client.indices.create index: index_name,
      body: {
        mappings: {
          record: {
            properties: {
              label: {
                type: 'string',
                analyzer: :english,
                fields: {
                  raw: {type: 'string', index: :not_analyzed }
                }
              },
              id: {type: 'string', index: :not_analyzed},
              records_count: {type: 'integer'},
              identifiers: {type: 'object', index: :not_analyzed }
            }
          }
        }
      }

    total = 0


    puts "Importing subjects into Elasticsearch…"

    Subject.find_in_batches do |records|
      puts "Importing records #{total + 1}–#{total + records.length}…"
      total = total + records.length

      body =
        records.map { |record|

          {
            index: {
              _index: index_name,
              _type:  'record',
              _id:    record.to_param,
              data:   record.to_elasticsearch
            }
          }
        }

      client.bulk body: body
    end

    puts "Finished importing #{total} records"

  end

end