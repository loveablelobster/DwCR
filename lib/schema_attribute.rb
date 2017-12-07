# frozen_string_literal: true

require 'nokogiri'

#
module DwCGemstone
  #
  class SchemaAttribute
    attr_accessor :alt_name, :default, :length
    attr_reader :name, :term, :index

    def initialize(field_node)
      @term = field_node.attributes['term']&.value
      @name = attribute_name(field_node)
      @alt_name = @name
      @index = field_node.attributes['index']&.value&.to_i
      @default = field_node.attributes['default']&.value
      @length = @default&.length
    end

    private

    def attribute_name(field_node)
      @term ? @term.split('/').last.underscore.to_sym : field_node.name.to_sym
    end
  end
end
