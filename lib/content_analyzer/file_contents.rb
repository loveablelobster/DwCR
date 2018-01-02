# frozen_string_literal: true

require 'csv'

require_relative 'column'

# set custom CSV::Converters
CSV::Converters[:safe_numeric] = lambda do |field|
  case field.strip
  when /^-?[0-9]+$/
    field.to_i
  when /^-?[0-9]*\.[0-9]+$/
    field.to_f
  else
    field
  end
end

CSV::Converters[:blank_to_nil] = lambda do |field|
  field&.empty? ? nil : field
end

#
module DwCR
  #
  class FileContents
    attr_reader :columns

    def initialize(file, col_attrs = [:col_type, :col_length])
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
      CSV.open(file, &:readline).size.times.collect { |i| i }
    end

    def load_table(file)
      CSV.read(file,
               headers: headers(file),
               converters: [:blank_to_nil, :safe_numeric, :date])
    end
  end
end
