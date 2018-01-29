# frozen_string_literal: true

require 'nokogiri'

#
module XMLParsable
  # Will raise error if the XML file is not valid
  def self.validate_meta(xml)
    raise ArgumentError 'Multiple Core nodes' if xml.css('core').size > 1
  end

  # Loads and parses the given _meta.xml_ file
  # gets the nodes for the _core_ and _extensions_
  # if no _Meta.xml_ is given, will try to load the _meta.xml_ file in _@path_
  def parse_meta(path = nil)
    # if nothing is given, search in the working directory
    path ||= Dir.pwd

    # set meta to default 'meta.xml' or the path
    meta = File.directory?(path) ? File.join(path, 'meta.xml') : path
    xml = File.open(meta) { |f| Nokogiri::XML(f) }

    # FIXME: this should adapt to wheteher the mixin is included into
    #        a MetaArchive, MetaEntity, or MetaAttribute
    # FIXME: add rescue
    XMLParsable.validate_meta xml
    load_entities_from xml
  end

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

  # Parses the names for files
  def files_from(xml)
    xml.css('files').css('location').map(&:text)
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
