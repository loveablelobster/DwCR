# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'


#
module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'

  #
  class ArchiveStore
    include Singleton

    attr_reader :db

    def connect(archive_path)
      @db = Sequel.sqlite(archive_path)
    end
  end
end
