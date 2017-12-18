# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'


#
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  # from: https://johnragan.wordpress.com/2010/02/18/ruby-metaprogramming-dynamically-defining-classes-and-methods/
  def self.create_model(model_name, source, *associations)
    c = Class.new(Sequel::Model(source)) do
    	associations.each do |association|
    	  associate(association[:type],
    	            association[:name],
    	            class: association[:class_name],
    	            class_namespace: 'DwCR',
    	            key: association[:key])
    	end
    end

    self.const_set model_name, c
  end

  #
  class ArchiveStore
    include Singleton

    attr_reader :db

    # currently also returns the connection
    def connect(archive_path = nil)
      @db = Sequel.sqlite(archive_path)
      create_meta_schema
      @db
    end

    def create_meta_schema
      create_schema_entities_table
      create_schema_attributes_table
      create_content_files_table
      require_relative 'models/schema_entity'
      require_relative 'models/schema_attribute'
      require_relative 'models/content_file'
    end

    def create_models
      core = SchemaEntity.first(is_core: true)
      core_id = "#{core.name.singularize}_id".to_sym
      extensions = SchemaEntity.where(is_core: false)
      SchemaEntity.each do |entity|
        class_name = entity.name.classify
        associations = if entity.is_core
          extensions.map do |extension|
            { type: :one_to_many,
              name: extension.table_name,
              class_name: extension.name.classify,
              key: core_id }
          end
        else
          [{ type: :many_to_one,
             name: core.name.singularize.to_sym,
             class_name: core.name.classify,
             key: :id }]
        end
        DwCR.create_model(class_name, entity.table_name, *associations)
      end
    end

    def create_schema
      core_id = SchemaEntity.first(is_core: true).name.singularize
      SchemaEntity.each do |entity|
        @db.create_table entity.table_name do
          primary_key :id
          entity.schema_attributes.each { |attribute| column(*attribute.column_schema) }
          next if entity.is_core
          column "#{core_id.to_sym}_id".to_sym, :integer
        end
      end
    end

    def has_contents?
      # check all tables that had content files associated
    end

    def has_meta_schema?
      # @db.schema(:schema_entities)
        # returns the schema for the given table as an array
        # use to check presence of certain columns?
      @db.table_exists?(:schema_attributes) && @db.table_exists?(:schema_entities) && @db.table_exists?(:content_files)
    end

    def has_schema?

    end

    private

    def create_schema_attributes_table
      @db.create_table? :schema_attributes do
        primary_key :id
        column :schema_entity_id, :integer
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
      @db.create_table? :schema_entities do
      	primary_key :id
        column :name, :string        # pluralized name of the extension
        column :term, :string        # the URI for the definition
      	column :is_core, :boolean    # FIXME: was: kind :core or :extension (there should be an option that there can only be one)
        column :key_column, :integer # FIXME: the key (id) column; was hash, should be integer; it's always a foreing key if the table != is_copre
      end
    end

    def create_content_files_table
      @db.create_table? :content_files do
        primary_key :id
        column :schema_entity_id, :integer
        column :name, :string
        column :path, :string
      end
    end
  end
end
