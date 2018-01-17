# frozen_string_literal: true

require 'sequel'

require_relative 'db/connection'
require_relative 'store/schematables'

# This module provides functionality to create a
# SQLite database from a DarwinCoreArchive
# and provides an ORM layer using http://sequel.jeremyevans.net
# Sequel::Model instances are created from the DwCA's meta.xml file
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'
end
