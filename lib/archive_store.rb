# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'


#
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  #
  class ArchiveStore
    include Singleton

    attr_reader :db

    # currently also returns the connection
    def connect(archive_path = nil)
      @db = Sequel.sqlite(archive_path)
      create_schema
      @db
    end

    def create_schema
      create_schema_attributes_table
      require_relative 'schema_attribute'
      create_schema_entities_table
      # require relative 'schema_entity'
      create_content_files_table
    end

    private

    def create_schema_attributes_table
      @db.create_table :schema_attributes do
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

    def create_schema_entities_table
      @db.create_table :schema_entities do
      	primary_key :id
        column :name, :string       # pluralized name of the extension
        column :term, :string       # the URI for the definition
      	column :is_core, :boolean   # FIXME: was: kind :core or :extension (there should be an option that there can only be one)
        column :key, :integer       # FIXME: the key (id) column; was hash, should be integer; it's always a foreing key if the table != is_copre
        #has_many :attributes,         # the column definitions
        #has_many :contents            # the names of the files containing the data
      end
    end

    def create_content_files_table
      @db.create_table :content_files do
        primary_key :id
        column :name
        column :path
      end
    end
  end
end
