require 'elasticsearch'

namespace :elasticsearch do


  desc 'Ingest people into elasticsearch'
  task people: :environment do

    logging = false
    index_name = 'people'

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: logging

    if client.indices.exists? index: index_name
      client.indices.delete index: index_name
    end

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
              all_names: {type: 'string', analyzer: :english },
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
      puts "Importing people #{total + 1}–#{total + records.length}…"
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


    if client.indices.exists? index: index_name
      client.indices.delete index: index_name
    end

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
              all_labels: {type: 'string', analyzer: :english},
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
      puts "Importing subjects #{total + 1}–#{total + records.length}…"
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

  desc 'Reset Records mappings (wipes all data)'
  task reset_records_mappings: :environment do

    logging = false
    index_name = 'records'

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: logging

    if client.indices.exists? index: index_name
      client.indices.delete index: index_name
    end

    client.indices.create index: index_name,
      body: {
        mappings: {
          record: {
            properties: {
              id: {type: 'string', index: :not_analyzed},
              title: {
                type: 'string',
                analyzer: :english,
                fields: {
                  raw: {type: 'string', index: :not_analyzed }
                }
              },
              digitized: {type: 'boolean'},
              year: {type: 'string', index: 'not_analyzed'},
              pdf_thumbnail_url: {type: 'string', index: :not_analyzed},
              cover_image_uris: {type: 'string', index: :not_analyzed},
              archives_ref: {type: 'string', index: :not_analyzed},
              subject_ids: {type: 'integer', index: :not_analyzed},
              person_ids: {type: 'integer', index: :not_analyzed},
              type_ids: {type: 'integer', index: :not_analyzed},
              collection_ids: {type: 'integer', index: :not_analyzed}
            }
          }
        }
      }

  end


  desc 'Ingest records into elasticsearch'
  task records: :environment do

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL'), log: logging

    total = 0

    puts "Importing records into Elasticsearch…"

    Record.find_in_batches do |records|
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


  desc 'Reset Collections mappings (wipes all data)'
  task reset_collections_mappings: :environment do

    logging = false
    index_name = 'collections'

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL')

    if client.indices.exists? index: index_name
      client.indices.delete index: index_name
    end

    client.indices.create index: index_name,
      body: {
        mappings: {
          collection: {
            properties: {
              id: {type: 'string', index: :not_analyzed},
              name: {
                type: 'string',
                analyzer: :english,
                fields: {
                  raw: {type: 'string', index: :not_analyzed }
                }
              },
              all_names: {type: 'string', analyzer: :english},
              description: {
                type: 'string',
                analyzer: :english,
                fields: {
                  raw: {type: 'string', index: :not_analyzed }
                }
              },
              records_count: {type: 'integer'},
              digitized_records_count: {type: 'integer'},
              slug: {type: 'string', index: :no},
              from_year: {type: 'integer'},
              to_year: {type: 'integer'}
            }
          }
        }
      }

  end


  desc 'Ingest collections into elasticsearch'
  task collections: :environment do

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL')
    index_name = 'collections'

    total = 0

    puts "Importing collections into Elasticsearch…"

    Collection.find_in_batches do |collections|
      puts "Importing collections #{total + 1}–#{total + collections.length}…"
      total = total + collections.length

      body =
        collections.map { |collection|

          {
            index: {
              _index: index_name,
              _type:  'collection',
              _id:    collection.id,
              data:   collection.to_elasticsearch
            }
          }
        }

      client.bulk body: body
    end

    puts "Finished importing #{total} records"

  end


  desc 'Reset Types mappings (wipes all data)'
  task reset_types_mappings: :environment do

    logging = false
    index_name = 'types'

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL')

    if client.indices.exists? index: index_name
      client.indices.delete index: index_name
    end

    client.indices.create index: index_name,
      body: {
        mappings: {
          collection: {
            properties: {
              name: {
                type: 'string',
                analyzer: :english,
                fields: {
                  raw: {type: 'string', index: :not_analyzed }
                }
              },
              all_names: {type: 'string', analyzer: :english},
              description: {
                type: 'string',
                analyzer: :english,
                fields: {
                  raw: {type: 'string', index: :not_analyzed }
                }
              },
              records_count: {type: 'integer'},
              digitized_records_count: {type: 'integer'}
            }
          }
        }
      }

  end

  desc 'Ingest type into elasticsearch'
  task types: :environment do

    client = Elasticsearch::Client.new url: ENV.fetch('ELASTICSEARCH_URL')
    index_name = 'types'

    total = 0

    puts "Importing types into Elasticsearch…"

    Type.find_in_batches do |types|
      puts "Importing types #{total + 1}–#{total + types.length}…"
      total = total + types.length

      body =
        types.map { |type|

          {
            index: {
              _index: index_name,
              _type:  'type',
              _id:    type.to_param,
              data:   type.to_elasticsearch
            }
          }
        }

      client.bulk body: body
    end

    puts "Finished importing #{total} records"

  end

end