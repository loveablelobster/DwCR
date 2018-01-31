# frozen_string_literal: true

require 'sequel'

require_relative 'db/schematables'
require_relative 'models/dynamic_models'

# This module provides functionality to create a
# SQLite database from a DarwinCoreArchive
# and provides an ORM layer using http://sequel.jeremyevans.net
# Sequel::Model instances are created from the DwCA's meta.xml file
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  # Creates the database schema for the DwCA nodes
  # _options_:
  # - +type:+ +true+ or +false+
  # - +length:+ +true+ or +false+
  # if options are given, the schema will be updated
  # based on the DwCA files actual content,
  # analysing each column for type and length
  def self.create_schema(archive, **options)
    update_schema(archive, options)
    archive.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
    DwCR.load_models(archive)
  end

  # Updates all MetaAttribute instances in a MetaArchive
  # with parameters from files in ContentFile
  # _schema_options_: a Hash with attribute names as keys and boolean values
  # <tt>{ :type => true, :length => true }</tt>
  # updates any attribute given as key where value is _true_
  def self.update_schema(archive, **options)
    return if options.empty?

    # FIXME: throw an error if metaschema is not loaded
    # FIXME: handle situation where schema tables have been created
    options.select! { |_k, v| v == true }
    archive.meta_entities
           .each { |entity| entity.update_meta_attributes!(*options.keys) }
  end

  # Loads the contents of all CSV files associated with an archive
  # into the shema tables
  def self.load_contents_for(archive)
    archive.core.content_files.each(&:load)
    archive.extensions.each do |extension|
      extension.content_files.each(&:load)
    end
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
end
