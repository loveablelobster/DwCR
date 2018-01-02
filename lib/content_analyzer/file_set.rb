# frozen_string_literal: true

require_relative 'file_contents'

#
module DwCR
  #
  class FileSet
    attr_accessor :col_attrs
    attr_reader :columns

    def initialize(files, col_attrs = [:col_type, :col_length])
      @col_attrs = col_attrs
      @columns = analyze files
    end

    def analyze(files)
      consolidate(files.map { |file| columns_for file }.flatten).to_h
    end

    def consolidate(files)
      files.group_by(&:header).map do |header, column|
        length = column.map(&:length).max
        types = column.map(&:type).uniq

        col_type = if types.size == 1
                     types.first
                   elsif types.size == 2 && types.include?(Float) && types.include?(Integer)
                     Float
                   else
                     String
                   end
        [header, { length: length, type: col_type }]
      end
    end

    def columns_for(file)
      FileContents.new(file, @col_attrs).columns
    end
  end
end
