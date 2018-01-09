# frozen_string_literal: true

require 'nokogiri'

#
module XMLParsable
  def default_for(field_def)
    field_def.attributes['default']&.value
  end

  def index_for(field_def)
    field_def.attributes['index']&.value&.to_i
  end

  # Parses the name for a file, table, or column
  def name_for(xml)
    # if the xml is a file definition
    is_file = xml.css('location')&.first
    return is_file.text if is_file

    # if the xml is a table or column definition
    term = term_for xml
    name = term&.split('/')&.last
    xml.attributes['rowType'] ? name.tableize : name&.underscore || 'coreid'
  end

  def term_for(xml)
    term = xml.attributes['rowType'] || xml.attributes['term']
    term&.value
  end

  def update_from_xml(xml, *fields)
    values = fields.map { |field| send((field.id2name + '_for').to_sym, xml) }
    update_hash = fields.zip(values).to_h.compact
    update update_hash
    save
  end
end
