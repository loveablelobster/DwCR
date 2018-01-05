# frozen_string_literal: true

#
module DwCR
  #
  class Column
    attr_reader :index, :type, :length

    def initialize(index, contents, *detectors)
      raise ArgumentError unless index.is_a? Integer
      detectors = [] if detectors.size == 1 && detectors.first == :none
      detectors = %i[type= length=] if detectors.size == 1 && detectors.first == :all
      detectors.map! { |d| (d.id2name + '=').to_sym }
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

    def length=(cells)
      @length = cells.map(&:to_s).map(&:length).max || 0
    end

    def type=(cells)
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
