# frozen_string_literal: true

require 'sequel'
require 'sqlite3'

#
module DwCR
  Sequel.extension :inflector
  require_relative '../inflections'

  def self.connect(path: nil)
    Sequel.sqlite(path)
  end
end
