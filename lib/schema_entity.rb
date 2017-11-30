# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'

#
module DwCGemstone
  #
  class SchemaEntity
    attr_reader :kind, :term

    def initialize(schema_node)
      # will be of structure:
      #   name = "[core]|[extensionname]"
      #   namespace = #(Namespace:{})
      #   attributes = []
      #   children = []
      # name will be table name
      # children holds column information
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
#       make_table(table_name, nil)
    end

    def make_table(table_name, columns)
      # check if table exists
      # if not, create it
      ArchiveStore.instance.db.create_table table_name do
      	primary_key :id
      end
    end
  end
end
