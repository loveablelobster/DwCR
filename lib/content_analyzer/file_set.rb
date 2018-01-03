# frozen_string_literal: true

require_relative 'file_contents'

#
module DwCR
  #
  class FileSet
    attr_reader :columns

    def initialize(files, detectors = %i[col_type col_length])
      @detectors = detectors
      @columns = analyze files
    end

    private

    def analyze(files)
      consolidate(files.map { |file| columns_for file }.flatten).to_h
    end

    def consolidate(files)
      files.group_by(&:header).map do |header, column|
        length = column.map(&:length).max
        types = column.map(&:type).uniq
        [header, { length: length, type: common_type(types) }]
      end
    end

    def columns_for(file)
      FileContents.new(file, @detectors).columns
    end

    def common_type(types)
      if types.size == 1
        types.first
      elsif types.size == 2 && types.include?(Float) && types.include?(Integer)
        Float
      else
        String
      end
    end
  end
end
