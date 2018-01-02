# frozen_string_literal: true

#
module DwCR

  #
  class Column
    attr_accessor :header
    attr_reader :type, :length

    def initialize(header, contents, calculate: [:col_type, :col_length])
      @header = header
      @type = nil
      @length = nil
      analyze(contents, calculate: calculate)
    end

    def analyze(contents, calculate: [])
      return if calculate.empty?
      cells = contents.compact
      calculate.each { |attr| self.send(attr, cells)}
    end

    private

    # when loading table this collapses all types encountered in a file's column into a single type
    def collapse(types)
      return types.first if types.size == 1
      return nil if types.empty? # or String
      return String if types.include?(String)
      return Float if types.size == 2 && types.include?(Float) && types.include?(Integer)
      String
    end

    def col_length(cells)
      @length = cells.map(&:to_s).map(&:length).max || 0
    end

    def col_type(cells)
      @type = collapse(cells.map(&:class).uniq)
    end
  end
end
