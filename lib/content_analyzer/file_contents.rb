# frozen_string_literal: true

require 'csv'

require_relative 'column'
require_relative 'csv_converters'

#
module DwCR
  #
  class FileContents
    attr_reader :columns

    def initialize(file, col_attrs = %i[col_type col_length])
      @file = file
      @col_attrs = col_attrs
      @columns = analyze
    end

    private

    def analyze
      table = load_table @file
      table.by_col!.map do |col|
        header = col[0]
        contents = col[1]
        Column.new(header, contents, calculate: @col_attrs)
      end
    end

    # reads the first line of the CSV file
    # returns the columns indices as an array
    def headers(file)
      Array.new(CSV.open(file, &:readline).size) { |i| i }
    end

    def load_table(file)
      CSV.read(file,
               headers: headers(file),
               converters: %i[blank_to_nil safe_numeric date])
    end
  end
end
