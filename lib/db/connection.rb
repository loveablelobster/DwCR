# frozen_string_literal: true

require 'sqlite3'

#
module DwCR
  def self.connect(path: nil)
    Sequel.sqlite(path)
  end
end
