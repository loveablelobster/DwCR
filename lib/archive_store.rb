# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'

require_relative 'inflections'

#
module DwCGemstone
  Sequel.extension :inflector

  #
  class ArchiveStore
    include Singleton

    attr_reader :db

    def connect(archive_path)
      @db = Sequel.sqlite(archive_path)
    end
  end
end
