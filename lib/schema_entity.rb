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
                # raise exception
              end
      @key = key_column(schema_node)
      @term = schema_node.attributes['rowType'].value
      table_name = @term.split('/').last.underscore.pluralize.to_sym
      @attributes = parse_fields(schema_node.css('field'))
      contents = schema_node.css('files')
#       make_table(table_name, nil)
    end

    private

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
      col_headers = []
      nodeset.map do |field|
        term = field.attributes['term'].value
        path = term.split('/')
        header = path.last.underscore
        col_name = col_headers.include?(header) ? path.push(header).join('_') : header
        [
          [:term, term],
          [:name, header.to_sym],
          [:index, field.attributes['index']&.value&.to_i],
          [:default, field.attributes['default']&.value]
        ].to_h.compact
      end
    end
  end
end
