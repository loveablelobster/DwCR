# frozen_string_literal: true

require 'csv'
require 'set'

#
module DwCR
  def self.analyze(files)
    columns = {}
    files.each do |file|
      CSV.foreach(file) do |row|
        row.each_with_index do |cell, index|

          columns[index] ||= { length: 0, type: nil}

          # fill lengths hash
          max_length = columns[index][:length]
          cell_length = cell&.length || 0
          columns[index][:length] = cell_length > max_length ? cell_length : max_length

          # fill content_types hash
          columns[index][:type] ||= Set.new
          ctype = case cell.strip # FIXME: also test for dates
                  when /^[0-9]+$/
                    :integer
                  when /^[0-9]*\.[0-9]+$/
                    :float
                  else
                    :string
                  end
          columns[index][:type].add? ctype

          # FIXME: when coordinate, can be float or int, or even string if '-'
          # if set is integer or float -> float
        end
      end
    end
#     content_type = types.length > 1 ? :string : types.first
    p columns
    columns
  end
end
