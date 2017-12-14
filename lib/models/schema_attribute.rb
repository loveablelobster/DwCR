# frozen_string_literal: true

require 'nokogiri'

#
module DwCR
  def self.parse_field_node(field_node)
    term = field_node.attributes['term']&.value

    # the coreid column of an extension will not have a term
    name = term ? term.split('/').last.underscore : field_node.name

    SchemaAttribute.create(
      term: term,
      name: name,
      alt_name: name,
      index: field_node.attributes['index']&.value&.to_i,
      default: field_node.attributes['default']&.value,
      has_index: false,
      is_unique: false
    )
  end

  #
  class SchemaAttribute < Sequel::Model
    # FIXME: name and alt_name are now strings, not symbols

    # FIXME: once the SchemaEntity has been rewritten, enable this
    # many_to_one :schema_entity

    def column_schema
      [alt_name, :string, { index: index_options, default: default }]
    end

    def index_options
      if has_index && is_unique
        { unique: true }
      elsif has_index
        true
      else
        false
      end
    end

    # FIXME: this may be redundant/confusing, remove and set the values instead?
    def index_options=(index_options)
      case index_options
      when true
      	has_index = true
      	is_unique = false
      when :unique
        has_index = true
        is_unique = true
      when :false
        has_index = false
        is_unique = false
      else
        raise ArgumentError
      end
    end

    # Returns the maximum string length for the attribute
    # which is the greater of either the length of the `default`
    # or the `max_content_length`
    # returns `nil`` if neither is set
    def length
      [default&.length, max_content_length].compact.max
    end
  end
end
