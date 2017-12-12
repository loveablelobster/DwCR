# frozen_string_literal: true

require 'nokogiri'

require_relative 'schema_entity'

#
module DwCR
  # holds all SchemaEntities
  class Schema
    attr_reader :entities

    def initialize(schema_def, options = { col_lengths: false })
      @options = options
      @entities = [SchemaEntity.new(schema_def.css('core').first, col_lengths: @options[:col_lengths])]
      @entities.concat(load_extensions(schema_def.css('extension')))
    end

    def core
      @entities.find { |entity| entity.kind == :core }
    end

    def entity(identifier)
      case identifier
      when String
        @entities.find { |entity| entity.term == identifier }
      when Symbol
        @entities.find { |entity| entity.name == identifier }
      else
        raise ArgumentError, "invalid argument: #{identifier.inspect}"
      end
    end

    # returns the extension by key
    def extension(name)
      extensions.find { |extension| extension.name == name  }
    end

    def extensions
      @entities.select { |entity| entity.kind == :extension }
    end

    private

    def load_extensions(node_set)
      node_set.css('extension').map { |extension| SchemaEntity.new(extension, col_lengths: @options[:col_lengths]) }
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
