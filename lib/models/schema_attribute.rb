# frozen_string_literal: true

require 'nokogiri'

#
module DwCR
  #
  class SchemaAttribute < Sequel::Model

    many_to_one :schema_entity

    def column_name
      alt_name.to_sym
    end

    # returns the parameters for column cration as an Array
    # for use withe the Sequel::Schema::CreatTableGenerator#column method
    # `#column(name, type, opts)`
    # usage: `column(*column_params)`
    def column_params
      [column_name, type.to_sym, { index: index_options, default: default }]
    end

    # Returns the index options for the column
    def index_options
      if has_index && is_unique
        { unique: true }
      elsif has_index
        true
      else
        false
      end
    end

    # Returns the maximum length for values in the column
    # which is the greater of either the length of the `default`
    # or the `max_content_length`
    # returns `nil` if neither is set
    def length
      [default&.length, max_content_length].compact.max
    end
  end
end
