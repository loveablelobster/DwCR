# frozen_string_literal: true

require 'nokogiri'
#
module DwCR
  #
  module Metaschema

#
module XMLParsable
  # Validates the meta.xml file
  # will raise errors if the file is not valid
  # currently only covers validation against multiple core instances
  def self.validate_meta(xml)
    raise ArgumentError, 'Multiple Core nodes' if xml.css('core').size > 1
    xml
  end

  # Loads the _meta.xml_ file from path
  # if _path_ is a directory, will try to locate the _meta.xml_ file in _path_
  # wil default to working directory if no _path_ is given
  def self.load_meta(path = nil)
    path ||= Dir.pwd
    meta = File.directory?(path) ? File.join(path, 'meta.xml') : path
    xml = File.open(meta) { |f| Nokogiri::XML(f) }
    XMLParsable.validate_meta xml
  end

  # Parses the _default_ value from an xml node
  # applies to _field_ nodes
  def default_from(xml)
    xml.attributes['default']&.value
  end

  # Returns +true+ id the xml node represenst the _core_
  # +false+ otherwise
  # applies to child nodes of _archive_ (entities)
  def is_core_from(xml)
    case xml.name
    when 'core'
      true
    when 'extension'
      false
    else
      raise ArgumentError, "invalid node name: '#{xml.name}'"
    end
  end

  # Returns the index of a _field_ node
  # or the _coreid_ of an _extension_ node
  # applies to _field_ and _extension_ nodes
  def index_from(xml)
    key_index = xml.css('coreid')&.first
    return xml.attributes['index']&.value&.to_i unless key_index
    key_index.attributes['index'].value.to_i
  end

  # Returns the index of the key column in
  # the _core_ (_id_)
  # or an _extension_ (_coreid_)
  # applies to child nodes of _archive_ (entities)
  def key_column_from(xml)
    key_tag = is_core_from(xml) ? 'id' : 'coreid'
    xml.css(key_tag).first.attributes['index'].value.to_i
  end

  # Returns an array with the names for any files
  # associated with a child node of _archive_ (_core_ or _extension_)
  # applies to child nodes of _archive_ (entities)
  def files_from(xml)
    xml.css('files').css('location').map(&:text)
  end

  # Returns the term for an entity or attribute
  # applies to _field_ nodes and child nodes of _archive_ (entities)
  def term_from(xml)
    term = xml.attributes['rowType'] || xml.attributes['term']
    term&.value
  end

  # Updates an instance of the model class the mixin is included in
  # with values parsed from xml
  # applies to _field_ nodes
  def update_from(xml, *fields)
    update values_from(xml, *fields)
    save
  end

  # Returns the XMLParsable method that corresponds to
  # the method name of the class the mixin is included to
  def method(method_name)
    method_name.to_s + '_from'
  end

  # Returns a hash with model attributes as keys,
  # values parsed from xml as values
  # applies to _field_ nodes
  def values_from(xml, *attrs)
    values = attrs.map { |attr| send(method(attr), xml) }
    attrs.zip(values).to_h.compact
  end
end
end
end
