# frozen_string_literal: true

require_relative 'file_contents'

#
module TableContents
  #
  class FileSet
    attr_reader :columns

    def initialize(files, detectors = %i[type length])
      @detectors = detectors
      @columns = analyze files
    end

    private

    def analyze(files)
      consolidate(files.map { |file| columns_for file }.flatten)
    end

    def consolidate(files)
      files.group_by(&:index).map do |index, column|
        length = column.map(&:length).max
        types = column.map(&:type).uniq
        { index: index,
          length: length,
          type: common_type(types)&.to_s&.underscore }
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
