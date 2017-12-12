# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'
require_relative 'schema'

#
module DwCR
  self.create_meta_schema(db)
    db.create_table :table_definitions do
      primary_key :id
    end

    db.create_table :column_definitions do
    	primary_key :id
    	column :name, :string
    	column :alt_name, :string
    	column :term, :string
    	column :default, :string
    	column :has_index, :boolean
    	column :is_unqique, :boolean
    	column :index, :integer
    	column :length, :integer
    end
  end

  class TableDefinition < Sequel::Model
    one_to_many :schema_attributes # in lib/schema_attribute
  end
end
