# frozen_string_literal: true

require 'nokogiri'

#
module XMLParsable
  def default_for(field_def)
    field_def.attributes['default']&.value
  end

  def is_core_for(xml)
    case xml.name
    when 'core'
      true
    when 'extension'
      false
    else
      Raise
    end
  end

  def index_for(field_def)
    field_def.attributes['index']&.value&.to_i
  end

  def key_column_for(xml)
    key_tag = is_core_for(xml) ? 'id' : 'coreid'
    xml.css(key_tag).first.attributes['index'].value.to_i
  end

  # Parses the name for a file, table, or column
  def name_for(xml)
    term = term_for xml
    is_file = xml.css('location')&.first

    # the xml is a file definition if no term is found but a location
    return is_file.text if is_file && !term

    # the xml is a table or column definition
    name = term&.split('/')&.last
    xml.attributes['rowType'] ? name.tableize : name&.underscore || 'coreid'
  end

  def term_for(xml)
    term = xml.attributes['rowType'] || xml.attributes['term']
    term&.value
  end

  def update_from_xml(xml, *fields)
    update value_hash(self, fields, xml)
    save
  end

  def model_from_xml(xml, model, *fields)
    model.create value_hash(self, fields, xml)
  end

  def method(field)
    field.id2name + '_for'
  end

  def value_hash(instance, fields, xml)
    values = fields.map { |field| instance.send(method(field), xml) }
    fields.zip(values).to_h.compact
  end
end
