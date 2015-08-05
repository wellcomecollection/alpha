require 'open-uri'
require 'json'
require 'nokogiri'
require 'digest'

class Person < ActiveRecord::Base

  has_many :creators
  has_many :records, through: :creators

  def to_param
    "P#{id}"
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

      images = response.fetch('parse', {}).fetch('images', []) - ["Commons-logo.svg"]

      images.reject! { |image| image =~ /\.svg\z/ }

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

  def wikipedia_image

    if wikipedia_images && wikipedia_images.length > 0

      file_name = wikipedia_images.first

      md5 = Digest::MD5.hexdigest file_name

      "https://upload.wikimedia.org/wikipedia/commons/#{md5[0]}/#{md5[0..1]}/#{URI.encode(file_name)}"
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

  def wikipedia_api_url
    if identifiers['wikipedia_en']
      "https://en.wikipedia.org/w/api.php?action=parse&format=json&page=#{URI.escape(identifiers['wikipedia_en'])}&contentmodel=wikitext"
    else
      nil
    end
  end

end
