# frozen_string_literal: true

require 'nokogiri'

#
module DwCR
  #
  class SchemaAttribute# < Sequel::Model
#     many_to_one :table_definition
    attr_accessor :alt_name, :default # these
    attr_reader :name, :term, :index  # can
    attr_writer :max_content_length   # all go

    #
    def initialize(field_node) # move column lengths to schema
      @term = field_node.attributes['term']&.value
      @name = attribute_name(field_node)
      @alt_name = @name
      @index = field_node.attributes['index']&.value&.to_i
      @default = field_node.attributes['default']&.value
      @max_content_length = nil
      @has_index = false
      @is_unique = false
    end

    def column_schema
      [alt_name, :string, { index: index_options, default: default }]
    end

    def index_options
      if @has_index && @is_unique
        { unique: true }
      elsif @has_index
        true
      else
        false
      end
    end

    def index_options=(index_options)
      case index_options
      when true
      	@has_index = true
      	@is_unique = false
      when :unique
        @has_index = true
        @is_unique = true
      when :false
        @has_index = false
        @is_unique = false
      else
        raise ArgumentError
      end
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
        length: length,
      	has_index: @has_index,
      	is_unique: @is_unique }.compact
    end


    private

    # move to module method
    def attribute_name(field_node)
      @term ? @term.split('/').last.underscore.to_sym : field_node.name.to_sym
    end
  end
end
