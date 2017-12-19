# frozen_string_literal: true

require 'csv'
require 'singleton'
require 'sequel'
require 'sqlite3'

require_relative 'models/dynamic_models'

#
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  #
  class ArchiveStore
    include Singleton

    attr_reader :db

    def connect(archive_path = nil)
      @db = Sequel.sqlite(archive_path)
      create_meta_schema
      @db
    end

    def core
      SchemaEntity.first(is_core: true)
    end

    def extensions
      SchemaEntity.where(is_core: false)
    end

    # gets the name of the foreign key from the core entity
    def foreign_key
      core.class_name.foreign_key
    end

    def create_meta_schema
      create_schema_entities_table
      create_schema_attributes_table
      create_content_files_table
      require_relative 'models/schema_entity'
      require_relative 'models/schema_attribute'
      require_relative 'models/content_file'
    end

    def create_schema
      SchemaEntity.each do |entity|
        create_schema_table(entity, foreign_key)
      end
      load_models
    end

    def load_contents
      load_core
      load_extensions
    end

    private

    # Create the Schema

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
        column :is_core, :boolean
        column :key_column, :integer
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

    def create_schema_table(entity, foreign_key)
      @db.create_table entity.table_name do
        primary_key :id
        entity.schema_attributes.each { |a| column(*a.column_schema) }
        next if entity.is_core
        column foreign_key, :integer
      end
    end

    # Create the Dynamic Models

    def association(left_entity, right_entity)
      options = { class: right_entity.class_name, class_namespace: 'DwCR' }
      if left_entity.is_core
        options[:key] = "#{left_entity.name.singularize}_id".to_sym
        [:one_to_many, right_entity.table_name, options]
      else
        options[:key] = :id
        [:many_to_one, right_entity.name.singularize.to_sym, options]
      end
    end

    def load_models
      core = SchemaEntity.first(is_core: true)
      extensions = SchemaEntity.where(is_core: false)
      SchemaEntity.each do |entity|
        assocs = if entity.is_core
                   extensions.map { |extension| association(entity, extension) }
                 else
                   [association(entity, core)]
                 end
        DwCR.create_model(entity.class_name, entity.table_name, *assocs)
      end
    end

    # Load Table Contents

    def load_core
      model = core.get_model
      return unless model.empty?
      files = core.content_files
      headers = core.content_headers
      path = Dir.pwd
      files.each do |file|
        filename = path + '/spec/files/' + file.name
        CSV.open(filename).each do |row|
          model.create(headers.zip(row).to_h)
        end
      end
    end

    def load_extensions
      extensions.each do |extension|
        next unless extension.get_model.empty?
        files = extension.content_files
        headers = extension.content_headers
        path = Dir.pwd
        files.each do |file|
          filename = path + '/spec/files/' + file.name
          CSV.open(filename).each do |row|
            data_row = headers.zip(row).to_h
            core_instance = core.get_model.first(core.key => row[extension.key_column])
            method_name = 'add_' + extension.name.singularize
            core_instance.send(method_name, data_row)
          end
        end
      end
    end
  end
end
