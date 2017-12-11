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

    def initialize(schema_node, options = { col_lengths: false })
      @options = options
      @kind = parse_kind(schema_node)
      @term = schema_node.attributes['rowType'].value
      @name = @term.split('/').last.underscore.to_sym
      @attributes = []
      parse_fieldset(schema_node)
      @key = key_column(schema_node)
      @contents = files(schema_node.css('files'))
    end

    def attribute(id)
      case id
      when String
        @attributes.find { |a| a.term == id }
      when Symbol
        @attributes.find { |a| a.alt_name == id || a.name == id }
      when Integer
        @attributes.find { |a| a.index == id }
      else
        raise ArgumentError
      end
    end

    def content_headers
      @attributes.select(&:index).sort_by(&:index).map(&:alt_name)
    end

    def update(attribute_lengths)
      attribute_lengths.each do |name, length|
        attribute(name).max_content_length = length
      end
    end

    private

    def files(schema_node)
      schema_node.map do |f|
        f.css('location').first.text
      end
    end

    def key_column(schema_node)
      if @kind == :core
        key = :primary
        tag = 'id'
        db_index = :unique
      else
        key = :foreign
        tag = 'coreid'
        db_index = true
      end
      key_index = schema_node.css(tag).first.attributes['index'].value.to_i
      attribute(key_index).db_index = db_index
      { key => attribute(key_index).alt_name }
    end

    def parse_fieldset(nodeset)
      nodeset.css('field').each do |field|
        if (existing = attribute(field.attributes['term'].value))
          existing.index ||= field.attributes['index']&.value&.to_i
          existing.default ||= field.attributes['default']&.value
        else
          new = SchemaAttribute.new(field, col_lengths: @options[:col_lengths])
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
