# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'
# require_relative 'schema'

#
module DwCR
  def self.create_meta_schema(db)
    db.create_table :schema_entities do
      primary_key :id
    end

    db.create_table :schema_attributes do
    	primary_key :id
    	column :name, :string
    	column :alt_name, :string
    	column :term, :string
    	column :default, :string
    	column :has_index, :boolean
    	column :is_unique, :boolean
    	column :index, :integer
      column :max_content_length, :integer
    end
  end

#   class TableDefinition < Sequel::Model
#     one_to_many :schema_attributes # in lib/schema_attribute
#   end
end
