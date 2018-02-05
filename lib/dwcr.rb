# frozen_string_literal: true

require 'sequel'

require_relative 'metaschema/metaschema'
require_relative 'models/dynamic_models'
require_relative 'dwca_content_analyzer/file_set'

# This module provides functionality to create a
# SQLite database from a DarwinCoreArchive
# and provides an ORM layer using http://sequel.jeremyevans.net
# Sequel::Model instances are created from the DwCA's meta.xml file
module DwCR
  Sequel.extension :inflector
  require_relative 'config/inflections'

  # Creates the table for +entity+ (a Entity instanc)
  # inserts foreign key for entities
  # skips the _coreid_ field declared in _extensions_ in the DwCA meta.xml
  # (this field is redundant, because relationships are re-established upon
  # import using SQL primary and foreign keys)
  # inserts the proper SQL foreign key into _extensions_
  # adds columns for any +attributes+ associated with +entity+
  def self.create_schema_table(entity)
    DB.create_table? entity.table_name do
      primary_key :id
      foreign_key :entity_id, :entities
      foreign_key entity.core.foreign_key, entity.core.table_name if entity.core
      entity.attributes.each do |a|
        column(*a.to_table_column) unless a.foreign_key?
      end
    end
  end

  # Creates the database schema for the DwCA nodes
  # _options_:
  # - +type:+ +true+ or +false+
  # - +length:+ +true+ or +false+
  # if options are given, the schema will be updated
  # based on the DwCA files actual content,
  # analysing each column for type and length
  def self.create_schema(archive, **options)
    Metaschema.update(archive, options)
    archive.entities.each { |entity| DwCR.create_schema_table(entity) }
  end

  # Loads models for all Entity instances in the Archive instance
  # if no explicit Archive instance is given, it will load the first
  def self.load_models(archive = Archive.first)
    archive.entities.map do |entity|
      entity_model = DwCR.create_model(entity)
      Metaschema::Entity.associate(:one_to_many,
                                       entity.table_name,
                                       class: entity_model)
      entity_model
    end
  end

  # Loads the contents of all CSV files associated with an archive
  # into the shema tables
  def self.load_contents_for(archive)
    archive.core.content_files.each(&:load)
    archive.extensions.each do |extension|
      extension.content_files.each(&:load)
    end
  end
end
