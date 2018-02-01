# frozen_string_literal: true

require 'sequel'

require_relative 'db/metaschema'
require_relative 'models/dynamic_models'

# This module provides functionality to create a
# SQLite database from a DarwinCoreArchive
# and provides an ORM layer using http://sequel.jeremyevans.net
# Sequel::Model instances are created from the DwCA's meta.xml file
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  def self.create_schema_table(entity)
    DB.create_table? entity.table_name do
      primary_key :id
      foreign_key :meta_entity_id, :meta_entities
      DwCR.add_foreign_key(self, entity)
      entity.meta_attributes.each do |a|
        column(*a.to_table_column) unless a.foreign_key?
      end
    end
  end

  def self.add_foreign_key(table, entity)
    return unless entity.core
    table.foreign_key(entity.core.foreign_key, entity.core.table_name)
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
    archive.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
  end

  # Loads models for all MetaEntity instances in the MetaArchive instance
  # if no explicit MetaArchive instance is given, it will load the first
  def self.load_models(archive = MetaArchive.first)
    archive.meta_entities.map do |entity|
      entity_model = DwCR.create_model(entity)
      MetaEntity.associate(:one_to_many,
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
