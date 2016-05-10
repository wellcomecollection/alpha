class PeopleController < ApplicationController

  before_filter :authorize, except: ['show', 'index']

  def index
    @top_people = Person
      .where("array_length(wikipedia_images, 1) > 0")
      .where('records_count > 4')
      .order('random()').limit(200)
  end

  def edit
    @person = Person.find(params[:id].gsub('P', ''))
  end

  def show

    client = Elasticsearch::Client.new

    id = params[:id].gsub("P", "")

    @person = Person.find(id)

    @digitized_count = @person.records.where(digitized: true).count

    results = client.search index: 'records',
      size: 100,
      body: {
        query: {
          term: {
            person_ids: @person.id
          }
        },
        sort: [{digitized: {order: 'desc'}}],
        aggs: {
          types: {
            terms: {
              field: 'type_ids',
              size: 16
            }
          }
        }
      }

    @things = results['hits']['hits'].collect do |hit|

      Record.new(
        identifier: hit['_source']['id'],
        title: hit['_source']['title'],
        cover_image_uris: hit['_source']['cover_image_uris']
      )
    end

    @types = Type.find(results['aggregations']['types']['buckets'].collect {|r| r['key'] })

    record_ids = @person.records.select(:id)

    if @person.born_in

      results = client.search index: 'records',
        size: 0,
        body: {
          query: {
            match: {
              person_ids: @person.id
            }
          },
          aggs: {
            subject_ids: {
              terms: {
                field: 'subject_ids',
                size: 0
              }
            }
          }
        }
      subject_ids = results['aggregations']['subject_ids']['buckets'].map { |bucket| bucket['key'] }

      results = client.search index: 'people',
        size: 0,
        body: {
          query: {
            range: {
              born_in: {
                gte: @person.born_in - 10,
                lte: @person.born_in + 10
              }
            }
          },
          aggs: {
            person_ids: {
              terms: {
                field: 'id',
                size: 1000
              }
            }
          }
        }
      person_ids = results['aggregations']['person_ids']['buckets'].map { |bucket| bucket['key'].sub(/^P/, '').to_i } - [@person.id]

      results = client.search index: 'records',
        size: 0,
        body: {
          query: {
            bool: {
              must: [
                { terms: { person_ids: person_ids } },
                { terms: { subject_ids: subject_ids } }
              ]
            }
          },
          aggs: {
            person_ids: {
              terms: {
                field: 'person_ids',
                size: 10
              }
            }
          }
        }
      subject_person_ids = results['aggregations']['person_ids']['buckets'].map { |bucket| bucket['key'] }

      @things_about_person = @person
        .records_as_subject
        .select(:identifier, :title, :pdf_thumbnail_url, :cover_image_uris)
        .order('digitized desc').limit(10)

      @contemporaries = Person.find(subject_person_ids).sort_by { |person| subject_person_ids.index(person.id) }
    end

    @publication_years = Record
      .select('year')
      .where("records.id IN (#{record_ids.to_sql})")
      .where.not(year: nil)
      .group('year')
      .order('year')
      .count

    @top_subjects_written_about = Subject
      .joins(:taggings)
      .select("subjects.*, count(taggings.id) as count")
      .where("taggings.record_id IN (#{record_ids.to_sql})")
      .group('subjects.id')
      .order('count desc')
      .limit(40)
  end

  def update
    @person = Person.find(params[:id].gsub('P', ''))
    @person.update_attributes(person_params)
    redirect_to person_url(@person)
  end

  private

  def person_params
    params.require(:person).permit(:highlighted)
  end

end
