
# This model represents a MARC record, which consists mostly of a 'leader' string field
# and metadata stored under 3-digit field names, which are sometimes further subdividied
# into parts using single-character letters or digits.
class MarcRecord

  def initialize(element)
    @element = element
  end

  def leader
    @leader ||= @element.xpath('marc:leader').first.content.to_s
  end

  def id
    datafield_subfield('907', 'a').to_s.gsub(".", "")
  end

  def title
    key_title = datafield_subfield('245', 'a')
    qualifying_title = datafield_subfield('245', 'b')

    [key_title, qualifying_title].compact.join(' ')
  end

  def metadata

    @metadata = {}

    datafields.each do |datafield|

      @metadata[datafield.attribute('tag').to_s] ||= []


      field = datafield.to_h
      field.delete('tag')

      datafield.xpath('marc:subfield').each do |subfield|
        field[subfield.attribute('code').to_s] = subfield.content.to_s
      end

      @metadata[datafield.attribute('tag').to_s] << field
    end

    control_fields.each do |field|
      @metadata[field.attribute('tag').to_s] ||= []
      @metadata[field.attribute('tag').to_s] << field.content.to_s
    end

    @metadata
  end

  private

  def datafield_subfield(tag_number, subfield_letter)

    datafield = datafield(tag_number)

    unless datafield.nil?
      element = datafield(tag_number).xpath('marc:subfield').detect {|e| e.attribute('code').to_s == subfield_letter }
      element ? element.content : nil
    end

  end

  def datafield(tag_number)
    datafields.detect {|element| element.attribute("tag").to_s == tag_number }
  end

  def datafields
    @datafields ||= @element.xpath('marc:datafield')
  end

  def control_fields
    @control_fields ||= @element.xpath('marc:controlfield')
  end

end