# frozen_string_literal: true

require 'nokogiri'

#
module XMLParsable
  def default_from(field_def)
    field_def.attributes['default']&.value
  end

  def is_core_from(xml)
    case xml.name
    when 'core'
      true
    when 'extension'
      false
    else
      Raise
    end
  end

  # returns the index of the field or coreid (if extension)
  def index_from(xml)
    key_index = xml.css('coreid')&.first
    return xml.attributes['index']&.value&.to_i unless key_index
    key_index.attributes['index'].value.to_i
  end

  def key_column_from(xml)
    key_tag = is_core_from(xml) ? 'id' : 'coreid'
    xml.css(key_tag).first.attributes['index'].value.to_i
  end

  # Parses the name for a file, table, or column
  def name_from(xml)
    term = term_from xml
    is_file = xml.css('location')&.first

    # the xml is a file definition if no term is found but a location
    return is_file.text if is_file && !term

    # the xml is a table or column definition
    name = term&.split('/')&.last
    xml.attributes['rowType'] ? name.tableize : name&.underscore || 'coreid'
  end

  def term_from(xml)
    term = xml.attributes['rowType'] || xml.attributes['term']
    term&.value
  end

  def update_from(xml, *fields)
    update values_from(xml, *fields)
    save
  end

  def method(field)
    field.id2name + '_from'
  end

  def values_from(xml, *fields)
    values = fields.map { |field| send(method(field), xml) }
    fields.zip(values).to_h.compact
  end
end
