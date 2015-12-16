require 'open-uri'
require 'json'
require 'nokogiri'
require 'digest'

class Person < ActiveRecord::Base

  has_many :creators
  has_many :records, through: :creators

  belongs_to :editorial_updated_by, class_name: 'User'

  before_save :set_editorial_updated_at, :set_editorial_to_null_if_both_blank

  def to_param
    "P#{id}"
  end

  def to_api
    {id: to_param, name: name, records_count: records_count}
  end

  def to_elasticsearch

    {
      name: name,
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

  def remove_full_stops_from_name!

    regex = /([a-z])\./
    match = name.match(regex)

    if match
      self.name = name.gsub(regex, $1)
      save!
    end

  end

  def parse_wikipedia_paragraph_into_sentences!

    if wikipedia_intro_paragraph

      self.wikipedia_intro = wikipedia_intro_paragraph
        .gsub(/\s?\([^\)]+\)/, '')                          # Remove anything in parenthesis
        .gsub(/\[(?:note\s)\d+\]/, '')                      # Remove Wikipedia references
        .split(/[\.](?:[\s]|$)/).collect {|x| x + '.' }     # Split into sentences (crudely)

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

  def set_other_identifiers_from_viaf!

    wikipedia_url_regxex = /\Ahttp\:\/\/([^\.]+).wikipedia.org\/wiki\/(.+)\z/

    if identifiers['loc']

      url = URI.escape("http://viaf.org/viaf/sourceID/LC%7C#{identifiers['loc']}/justlinks.json")

      begin
        open(url) do |file|

          viaf_concordances = JSON.parse(file.read)

          identifiers['viaf'] = viaf_concordances["viafID"]

          viaf_concordances.except("viafID", "LC", "Wikipedia").each_pair do |key, value|
            identifiers[key.downcase] ||= value.to_a.first
          end

          viaf_concordances["Wikipedia"].to_a.each do |wikipedia_url|

            wikipedia_language = wikipedia_url[wikipedia_url_regxex, 1]
            wikipedia_slug = wikipedia_url[wikipedia_url_regxex, 2]

            identifiers["wikipedia_#{wikipedia_language}"] ||= wikipedia_slug

          end

          save!

        end

      rescue OpenURI::HTTPError
        puts "Error: #{url}"
      end

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

  def wikipedia_api_url
    if identifiers['wikipedia_en']
      "https://en.wikipedia.org/w/api.php?action=parse&format=json&page=#{URI.escape(identifiers['wikipedia_en'])}&contentmodel=wikitext"
    else
      nil
    end
  end

end
