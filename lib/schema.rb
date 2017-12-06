# frozen_string_literal: true

require 'nokogiri'

require_relative 'schema_entity'

#
module DwCGemstone
  # holds all SchemaEntities
  class Schema
    def initialize(schema_def)
      @entities = [SchemaEntity.new(schema_def.css('core').first)]
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
      node_set.css('extension').map { |extension| SchemaEntity.new(extension) }
    end
  end
end
