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

#     def method_missing(name, *args, &block)
#       @db.send(name, *args, &block) || super
#     end
#
#     def respond_to_missing?(name, include_private = false)
#       @db.respond_to?(name, include_private) || super
#     end
  end
end
