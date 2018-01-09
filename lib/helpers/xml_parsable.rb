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

  def name_for(xml)
    term = term_for xml
    name = term&.split('/')&.last
    xml.attributes['rowType'] ? name.tableize : name&.underscore || 'coreid'
  end

  def path_for(xml)
    xml.css('location').first.text
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
