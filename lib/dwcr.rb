# frozen_string_literal: true

require 'sequel'

require_relative 'db/connection'
require_relative 'store/schematables'

module DwCR
  Sequel.extension :inflector
  require_relative 'inflections'
end
