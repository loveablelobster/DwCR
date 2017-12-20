# frozen_string_literal: true

require 'csv'

#
module DwCR
  def self.column_lengths(files)
    lengths = {}
    files.each do |file|
      CSV.foreach(file) do |row|
        row.each_with_index do |cell, index|
          watermark = lengths[index] || 0
          cell_length = cell&.length || 0
          lengths[index] = cell_length > watermark ? cell_length : watermark
        end
      end
    end
    lengths
  end
end
