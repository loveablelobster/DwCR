# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'

#
module DwCGemstone
  #
  class SchemaEntity
    attr_reader :kind, :term

    def initialize(schema_node)
      @kind = case schema_node.name
              when 'core'
                :core
              when 'extension'
                :extension
              else
                # raise exception
              end
      @term = schema_node.attributes['rowType'].value
      table_name = @term.split('/').last.underscore.pluralize.to_sym
      fields = schema_node.css('field')
      contents = schema_node.css('files')
#       make_table(table_name, nil)
    end

    private

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
        term = field.attributes['term']
        path = term.split('/')
        header = path.last.underscore
        col_name = col_headers.include?(header) ? : [path, header].join('_')
        [
          [:term, term],
          [:name, header],
          [:index, field.attributes['index']],
          [:default, field.attributes['value']]
        ].to_h
      end
    end
  end
end
