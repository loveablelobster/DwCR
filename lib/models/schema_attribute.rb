# frozen_string_literal: true

require 'nokogiri'
require_relative '../helpers/xml_parsable'

#
module DwCR
  #
  class SchemaAttribute < Sequel::Model
    include XMLParsable

    many_to_one :schema_entity

    def column_name
      name.to_sym
    end

    # returns the parameters for column cration as an Array
    # for use withe the Sequel::Schema::CreatTableGenerator#column method
    # `#column(name, type, opts)`
    # usage: `column(*column_params)`
    def column_params
      [column_name, type.to_sym, { index: index_options, default: default }]
    end

    # Returns the maximum length for values in the column
    # which is the greater of either the length of the `default`
    # or the `max_content_length`
    # returns `nil` if neither is set
    def length
      [default&.length, max_content_length].compact.max
    end

    def length=(new_length)
      self.max_content_length = new_length
    end

    private

    # Returns the index options for the column
    def index_options
      if schema_entity.is_core && index == schema_entity.key_column
        { unique: true }
      elsif index == schema_entity.key_column
        true
      else
        false
      end
    end
  end
end
