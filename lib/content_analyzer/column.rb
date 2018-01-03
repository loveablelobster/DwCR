# frozen_string_literal: true

#
module DwCR
  #
  class Column
    attr_reader :index, :type, :length

    def initialize(index, contents, detectors = %i[col_type col_length])
      raise ArgumentError unless index.is_a? Integer
      detectors = [] if detectors == :none
      detectors = [detectors] if detectors.is_a? Symbol
      @index = index
      @type = nil
      @length = nil
      analyze(contents, detectors)
    end

    private

    def analyze(contents, detectors)
      return if detectors.empty?
      cells = contents.compact
      detectors.each { |detector| send(detector, cells) }
    end

    # collapses all types encountered in a file's column into a single type
    def collapse(types)
      return types.first if types.size == 1
      return nil if types.empty? # or String
      return String if string?(types)
      return Float if float?(types)
      String
    end

    def col_length(cells)
      @length = cells.map(&:to_s).map(&:length).max || 0
    end

    def col_type(cells)
      @type = collapse(cells.map(&:class).uniq)
    end

    def float?(types)
      types.size == 2 && types.include?(Float) && types.include?(Integer)
    end

    def string?(types)
      types.include?(String)
    end
  end
end
