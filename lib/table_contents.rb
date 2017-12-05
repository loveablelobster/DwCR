# frozen_string_literal: true

require 'csv'

#
module DwCGemstone
  # schema: a SchemaEntity
  class TableContents
    attr_reader :name, :table
    def initialize(path, schema)
      @columns = schema.attributes
      @name = schema.name
      @file = Pathname.new(path + schema.contents).sub_ext('.dwc')
      make_table(path + schema.contents)
      @table = CSV.table(@file, converters: nil)
    end

    def max_length(col)
      # FIXME: move the default width test to the SchemaEntity
      col_def = @columns.find { |c| c[:index] == col || c[:name] == col }
      default_width = col_def[:default]&.length || 0
      max_cell_width = @table.by_col[col].map { |cell| cell&.length || 0 }.max
      max_cell_width > default_width ? max_cell_width : default_width
    end

    private

    def make_table(file)
      headers = @columns.select { |c| c[:index] }
                      .sort_by { |c| c[:index] }
                      .map { |c| c[:name] }
      CSV.open(@file, 'w', write_headers: true, headers: headers) do |dest|
        CSV.open(file) do |source|
          source.each { |row| dest << row }
        end
      end
    end
  end
end
