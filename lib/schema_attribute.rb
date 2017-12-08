# frozen_string_literal: true

require 'nokogiri'

#
module DwCGemstone
  #
  class SchemaAttribute
    attr_accessor :alt_name, :length
    attr_reader :name, :term, :index, :default

    def initialize(field_node, options = { col_lengths: false })
      @options = options
      @term = field_node.attributes['term']&.value
      @name = attribute_name(field_node)
      @alt_name = @name
      @index = field_node.attributes['index']&.value&.to_i
      @default = field_node.attributes['default']&.value
      @length = @options[:col_lengths] ? @default&.length : nil
    end

    def default=(new_default)
      @default = new_default
      @length = @default&.length
    end

    def to_h
      { term: @term, name: @alt_name, index: @index, default: @default }.compact
    end

    private

    def attribute_name(field_node)
      @term ? @term.split('/').last.underscore.to_sym : field_node.name.to_sym
    end
  end
end
