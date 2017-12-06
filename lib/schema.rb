# frozen_string_literal: true

require 'nokogiri'

require_relative 'schema_entity'

#
module DwCGemstone
  # holds all SchemaEntities
  class Schema
    attr_reader :core

    def initialize(schema_def)
      @core = SchemaEntity.new(schema_def.css('core').first)
      @extensions = {}
    end

    # returns the extension by key
    def extension()

    end
  end
end
