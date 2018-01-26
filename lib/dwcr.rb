# frozen_string_literal: true

require 'sequel'

require_relative 'db/connection'
require_relative 'db/schematables'

# This module provides functionality to create a
# SQLite database from a DarwinCoreArchive
# and provides an ORM layer using http://sequel.jeremyevans.net
# Sequel::Model instances are created from the DwCA's meta.xml file
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  # Loads the contents of all CSV files associated with an archive
  # into the shema tables
  def self.load_contents_for(archive)
    archive.core.content_files.each(&:load)
    archive.extensions.each do |extension|
      extension.content_files.each(&:load)
    end
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
end
