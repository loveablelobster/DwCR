# frozen_string_literal: true

require 'nokogiri'

#
module DwCGemstone
  #
  class SchemaAttribute
    attr_accessor :alt_name, :default
    attr_reader :name, :term, :index
    attr_writer :max_content_length

    #
    def initialize(field_node, options = { col_lengths: false })
      @options = options
      @term = field_node.attributes['term']&.value
      @name = attribute_name(field_node)
      @alt_name = @name
      @index = field_node.attributes['index']&.value&.to_i
      @default = field_node.attributes['default']&.value
      @max_content_length = nil
    end

    # Returns the maximum string length for the attribute
    # which is the greater of either the length of the `default`
    # or the `max_content_length`
    # returns `nil`` if neither is set
    def length
      [@default&.length, @max_content_length].compact.max
    end

    #
    def to_h
      { term: @term,
        name: @name,
        alt_name: @alt_name,
        index: @index,
        default: @default,
        length: length }.compact
    end

    private

    def attribute_name(field_node)
      @term ? @term.split('/').last.underscore.to_sym : field_node.name.to_sym
    end
  end
end
