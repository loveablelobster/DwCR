# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'

#
module DwCGemstone
  #
  class SchemaEntity
    attr_reader :kind, :term, :attributes, :key

    def initialize(schema_node)
      @kind = case schema_node.name
              when 'core'
                :core
              when 'extension'
                :extension
              else
                raise RuntimeError, "invalid node: #{schema_node.name}"
              end
      @key = key_column(schema_node)
      @term = schema_node.attributes['rowType'].value
      table_name = @term.split('/').last.underscore.pluralize.to_sym
      parse_fields(schema_node.css('field'))
      @attributes.unshift(name: :coreid, index: @key[:foreign]) if @kind == :extension
      contents = schema_node.css('files')
#       make_table(table_name, nil)
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

    def make_table(table_name, columns)
      # check if table exists
      # if not, create it
      ArchiveStore.instance.db.create_table table_name do
        primary_key :id
      end
    end

    def parse_fields(nodeset)
      @attributes = [] # FIXME: should be @attributes
      nodeset.each do |field|
        term = field.attributes['term'].value
        name = column_name(term)
        index = field.attributes['index']&.value&.to_i
        default = field.attributes['default']&.value
        col_def = { term: term, name: name, index: index, default: default }
        upsert(col_def)
      end
    end

    def upsert(col_def)
      if (column = @attributes.find { |c| c[:term] == col_def[:term] })
        column[:index] ||= col_def[:index]
        column[:default] ||= col_def[:default]
      else
        @attributes << col_def.compact
      end
    end
  end
end
