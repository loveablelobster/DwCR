# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'

#
module DwCGemstone
  #
  class SchemaEntity
    attr_reader :kind, :name, :term, :attributes, :key, :contents

    def initialize(schema_node)
      @kind = parse_kind(schema_node)
      @key = key_column(schema_node)
      @term = schema_node.attributes['rowType'].value
      @attributes = []
      parse_fieldset(schema_node.css('field'))
      @contents = schema_node.css('files').first.css('location').first.text
      @name = File.basename(@contents, '.*')
    end

    private

    def column_name(term)
      s = term.split('/').last.underscore
      n = s.to_sym
      return n unless @attributes.find { |a| a[:name] == n && a[:term] != term }
      s += '!'
      s.to_sym
    end

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

    def parse_field(field)
      term = field.attributes['term'].value
      { term: term,
        name: column_name(term),
        index: field.attributes['index']&.value&.to_i,
        default: field.attributes['default']&.value }
    end

    def parse_fieldset(nodeset)
      nodeset.each { |field| upsert_attribute(parse_field(field)) }
      return if @kind == :core
      @attributes.unshift(name: :coreid, index: @key[:foreign])
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

    def upsert_attribute(hash)
      if (column = @attributes.find { |c| c[:term] == hash[:term] })
        column[:index] ||= hash[:index]
        column[:default] ||= hash[:default]
      else
        @attributes << hash.compact
      end
    end
  end
end

#     def make_table(table_name, columns)
#       table_name = @term.split('/').last.underscore.pluralize.to_sym
#       # check if table exists
#       # if not, create it
#       ArchiveStore.instance.db.create_table table_name do
#         primary_key :id
#       end
#     end
