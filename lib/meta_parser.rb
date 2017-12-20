# frozen_string_literal: true

require 'nokogiri'
require 'sequel'

#
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  def self.parse_meta(meta_xml, options = { col_lengths: false })
    entities = []
    entities << parse_core(meta_xml.css('core'))
    entities.concat parse_extensions(meta_xml.css('extension'))
  end

  private

  def self.entity_hash(node, is_core:)
    tag = is_core ? 'id' : 'coreid'
    hash = name_term_hash(node)
    hash[:is_core] = is_core
    hash[:schema_attributes] = parse_fieldset(node)
    hash[:key_column] = key_column(node, tag, hash[:schema_attributes])
    hash[:content_files] = parse_content_files node.css('files')
    hash
  end

  def self.index_options(hash)
    hash[:schema_attributes].each do |field|
      next unless field[:index] == hash[:key_column]
      field[:has_index] = true
      break unless hash[:is_core]
      field[:is_unique] = true
      break
    end
    hash
  end

  def self.key_column(node, tag, fields)
    node.css(tag).first.attributes['index'].value.to_i
  end

  def self.name_term_hash(node)
    hash = { term: node.attributes['rowType'].value }
    hash[:name] = hash[:term].split('/').last.tableize
    hash
  end

  def self.parse_content_files(nodeset)
    nodeset.map do |file|
      { name: file.css('location').first.text }
    end
  end

  def self.parse_core(node)
    raise 'Invalid meta.xml: multiple core files: #{node}' if node.size > 1
    index_options(entity_hash(node.first, is_core: true))
  end

  def self.parse_extensions(nodeset)
    nodeset.map do |node|
      hash = entity_hash(node, is_core: false)
      hash[:schema_attributes].unshift(parse_field_node(node.css('coreid').first))
      index_options(hash)
    end
  end

  def self.parse_field_node(node)
    hash = { term: node.attributes['term']&.value }
    hash[:name] = hash[:term]&.split('/')&.last&.underscore || node.name
    hash[:alt_name] = hash[:name]
    hash[:index] = node.attributes['index']&.value&.to_i
    hash[:default] = node.attributes['default']&.value
    hash[:has_index] = false
    hash[:is_unique] = false
    hash
  end

  def self.parse_fieldset(node)
    attributes = []
    node.css('field').each do |field|
      if (existing = attributes.find { |a| a[:term] == field.attributes['term'].value })
        existing[:index] ||= field.attributes['index']&.value&.to_i
        existing[:default] ||= field.attributes['default']&.value
      else
        new = parse_field_node(field)
        new[:alt_name] = new[:name] + '!' if attributes.find { |a| a[:name] == new[:name] }
        attributes << new
      end
    end
    attributes
#     return if @kind == :core
#     attributes.unshift(SchemaAttribute.new(nodeset.css('coreid').first))
  end
end

#     contents = files(schema_node.css('files'))
