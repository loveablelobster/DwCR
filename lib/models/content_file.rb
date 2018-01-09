# frozen_string_literal: true

require 'csv'

#
module DwCR
  #
  class ContentFile < Sequel::Model
    many_to_one :schema_entity

    def load_file(path)
      CSV.open(File.join(path, name)).each do |row|
        schema_entity.load_row(row)
      end
    end
  end
end
