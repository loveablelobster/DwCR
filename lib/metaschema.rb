# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'
require_relative 'schema'

#
module DwCR
  class TableDefinition < Sequel::Model
    one_to_many :column_definitions
  end

  class ColumnDefinition < Sequel::Model
    many_to_one :table_definition
  end
end
