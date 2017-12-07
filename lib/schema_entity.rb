# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store' # needed for sequel string and inflections
require_relative 'schema_attribute'

#
module DwCGemstone
  #
  class SchemaEntity
    attr_reader :kind,       # :core or :extension
                :term,       # the URI for the definition
                :name,       # short name of the extension, e.g. :occurrence
                :attributes, # the column definitions
                :key,        # the key (id) column
                :contents    # the names of the files containing the data

    def initialize(schema_node)
      @kind = parse_kind(schema_node)
      @key = key_column(schema_node) # FIXME: necessary?
      @term = schema_node.attributes['rowType'].value
      @name = @term.split('/').last.underscore.to_sym
      @attributes = []
      parse_fieldset(schema_node)
      @contents = files(schema_node.css('files'))
    end

    def attribute(id)
      case id
      when String
        @attributes.find { |a| a.term == id }
      when Symbol
        @attributes.find { |a| a.name == id || a.alt_name == id }
      when Integer
        @attributes[id]
      else
        raise ArgumentError
      end
    end

    def content_headers
      @attributes.select(&:index).sort_by(&:index).map(&:alt_name)
    end

    private

    def files(schema_node)
      schema_node.map do |f|
        f.css('location').first.text
      end
    end

    # FIXME: necessary?
    def key_column(schema_node)
      if @kind == :core
        key = :primary
        tag = 'id'
      else
        key = :foreign
        tag = 'coreid'
      end
      { key => schema_node.css(tag).first.attributes['index'].value.to_i }
    end

    def parse_fieldset(nodeset)
      nodeset.css('field').each do |field|
        if (existing = attribute(field.attributes['term'].value))
          existing.index ||= field.attributes['index']&.value&.to_i
          existing.default ||= field.attributes['default']&.value
        else
          new = SchemaAttribute.new(field)
          new.alt_name = new.name.id2name.concat('!').to_sym if attribute(new.name)
          @attributes << new
        end
      end
      return if @kind == :core
      @attributes.unshift(SchemaAttribute.new(nodeset.css('coreid').first))
    end

    def parse_kind(schema_node)
      case schema_node.name
      when 'core'
        :core
      when 'extension'
        :extension
      else
        raise "invalid node: #{schema_node.name}"
      end
    end
  end
end
