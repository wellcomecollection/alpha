require 'open-uri'
require 'json'
require 'nokogiri'
require 'digest'

class Person < ActiveRecord::Base

  has_many :creators, dependent: :restrict_with_exception
  has_many :records, through: :creators

  has_many :person_as_subjects, dependent: :destroy, class_name: 'PersonAsSubject'
  has_many :records_as_subject, through: :person_as_subjects, class_name: 'Record', source: :record

  belongs_to :editorial_updated_by, class_name: 'User'
  belongs_to :wellcome_intro_updated_by, class_name: 'User'

  before_save :set_editorial_updated_at, :set_editorial_to_null_if_both_blank
  before_save :set_wellcome_intro_updated_at, if: :wellcome_intro_changed?
  before_save :set_wellcome_intro_to_null, if: "wellcome_intro.blank?"

  scope :highlighted, -> { where(highlighted: true) }

  def to_param
    "P#{id}"
  end

  def to_api
    {id: to_param, name: name, records_count: records_count}
  end

  def to_elasticsearch

    {
      name: name,
      all_names: all_names,
      id: to_param,
      records_count: records_count,
      identifiers: identifiers,
      born_in: born_in,
      died_in: died_in,
      wikipedia_intro_paragraph: wikipedia_intro_paragraph
    }

  end

  def editorial
    editorial_title ? true : false
  end

  def wikipedia_sentences(number)
    wikipedia_intro.first(number).collect do |s|
      s.gsub(/\[\d+\]/, '')                 # Remove Wikipedia references
      .gsub(/\s?\([^\)]+\)/, '')            # Remove anything in parenthesis
      .gsub(/\.\.+\z/, '.')                 # Remove extra full stops at the end of each sentence
    end.join(' ')
  end

  def self.find_by_id_or_name_and_dates(id, name, born_in, died_in)

    if id.present?
      person = where(["identifiers->'loc' = ? ", id]).take
    end

    if born_in.present? || died_in.present?
      person ||= where(["LOWER(name) = ?", name.downcase])
        .where(born_in: born_in)
        .where(died_in: died_in)
        .order('records_count desc').take
    end

    person ||= where(["LOWER(name) = ?", name.downcase]).order('records_count desc').take

    person
  end


  def parse_wikipedia_paragraph_into_sentences!

    if wikipedia_intro_paragraph

      self.wikipedia_intro = wikipedia_intro_paragraph
        .gsub(/\s?\([^\)]+\)/, '')                          # Remove anything in parenthesis
        .gsub(/\[(?:note\s)\d+\]/, '')                      # Remove Wikipedia references
        .split(/(?<! [A-Z]\.| Sgt\.)(?<=\.) +/)             # Split into sentences (less crudely)

      save!
    end

  end

  def update_from_wikipedia!

    if identifiers['wikipedia_en']

      response = JSON.parse(open(wikipedia_api_url).read)

      # TODO: figure out why my local openssl installation doesn't have up-to-date certs
      # response = JSON.parse(open(wikipedia_api_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)

      images = response.fetch('parse', {}).fetch('images', [])

      images.reject! do |image|
        (image =~ /\.svg\z/) ||
        (image =~ /\.flac\z/) ||
        (image == 'Crystal_Clear_app_Login_Manager_2.png')
      end

      self.wikipedia_images = images

      text = response.fetch('parse', {}).fetch('text', {})['*']

      if text
        first_paragraph = Nokogiri::HTML(text).css('p').first.content

        if first_paragraph
          self.wikipedia_intro_paragraph = first_paragraph
          parse_wikipedia_paragraph_into_sentences!
        end
      end

      save!
    end

  end

  def wikipedia_image(width = 300)

    if wikipedia_images && wikipedia_images.length > 0

      file_name = wikipedia_images.reject do |f|
        (f =~ /\.flac\z/) ||
        (f == 'Crystal_Clear_app_Login_Manager_2.png')
      end.first


      if file_name
        md5 = Digest::MD5.hexdigest file_name

        "https://upload.wikimedia.org/wikipedia/commons/thumb/#{md5[0]}/#{md5[0..1]}/#{URI.encode(file_name)}/#{width}px-#{URI.encode(file_name)}"
      end
    else
      nil
    end

  end

  def update_wikipedia_intro!

    if identifiers['wikipedia_en']

      response = JSON.parse(open(wikipedia_api_url))

    end
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

  def set_wellcome_intro_updated_at
    write_attribute(:wellcome_intro_updated_at, Time.now)
  end

  def set_wellcome_intro_to_null
    write_attribute(:wellcome_intro, nil)
  end

  def wikipedia_api_url
    if identifiers['wikipedia_en']
      "https://en.wikipedia.org/w/api.php?action=parse&format=json&page=#{URI.escape(identifiers['wikipedia_en'])}&contentmodel=wikitext"
    else
      nil
    end
  end

end
