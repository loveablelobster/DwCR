# frozen_string_literal: true

require 'csv'
require 'psych'
require 'singleton'
require 'sequel'
require 'sqlite3'

require_relative '../content_analyzer/file_set'
require_relative '../models/dynamic_models'

#
module DwCR
  Sequel.extension :inflector
  require_relative '../inflections'

  #
  class ArchiveStore
    include Singleton

    attr_reader :db

    # path: path to the SQLite `.db` file, will store in memory if none given
    def connect(path: nil)
      @db = Sequel.sqlite(path)
      create_meta_schema
      @db
    end

    def reset
      @db.disconnect
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
      connect unless @db
      table_defs = Psych.load_file('lib/store/metaschema.yml')
      table_defs.each do |td|
        @db.create_table? td.first do
          primary_key :id
          td.last.each { |c| column(*c) }
        end
      end
      require_relative '../models/schema_entity'
      require_relative '../models/schema_attribute'
      require_relative '../models/content_file'
    end

    # schema option:
    # - :col_type => true   # will set column types other than string
    # - :col_length => true # will set lengths for (string) columns
    def create_schema(**schema_options)
      update_schema(schema_options)
      SchemaEntity.each do |entity|
        create_schema_table(entity, foreign_key)
      end
      load_models
    end

    def load_contents
      load_core
      load_extensions
    end

    def update_schema(schema_options)
      return unless schema_options

      detectors = schema_options.keys

      SchemaEntity.each do |entity|
        files = entity.content_files.map { |file| Dir.pwd + '/spec/files/' + file.name } # FIXME: path!
        col_params = FileSet.new(files, detectors).columns
        col_params.each do |cp|
          column = entity.schema_attributes_dataset.first(index: cp[:index])
          column[:type] = cp[:type].to_s.underscore if cp[:type] && schema_options[:col_type]
          column[:max_content_length] = cp[:length] if schema_options[:col_length]
          column.save
        end
      end
    end

    private

    # Create the tables for the DwCA Schema
    def create_schema_table(entity, foreign_key)
      @db.create_table? entity.table_name do
        primary_key :id
        entity.schema_attributes.each { |a| column(*a.column_params) }
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
        options[:key] = "#{right_entity.name.singularize}_id".to_sym
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
      return unless core.get_model.empty?
      files = core.content_files
      headers = core.content_headers
      path = Dir.pwd
      files.each do |file|
        filename = path + '/spec/files/' + file.name # FIXME: path!
        CSV.open(filename).each do |row|
          core.get_model.create(headers.zip(row).to_h)
        end
      end
    end

    def load_extensions
      extensions.each do |extension|
        next unless extension.get_model.empty?
        headers = extension.content_headers
        path = Dir.pwd
        extension.content_files.each do |file|
          filename = path + '/spec/files/' + file.name # FIXME: path!
          CSV.open(filename).each do |row|
            data_row = headers.zip(row).to_h
            core_instance = core.get_model
                                .first(core.key => row[extension.key_column])
            method_name = 'add_' + extension.name.singularize
            core_instance.send(method_name, data_row)
          end
        end
      end
    end
  end
end
