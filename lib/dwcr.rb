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
end
