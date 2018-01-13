# frozen_string_literal: true

require 'csv'

#
module DwCR
  #
  class ContentFile < Sequel::Model
    many_to_one :meta_entity

    def file_name
      File.join(path, name)
    end

    def load
      CSV.open(File.join(path, name)).each do |row|
        meta_entity.load_row(row)
      end
    end
  end
end
