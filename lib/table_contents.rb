# frozen_string_literal: true

require 'csv'

#
module DwCGemstone
  #
  class TableContents
    attr_reader :table
    def initialize(contents_path, schema)
      @schema = schema
      @file = Pathname.new(contents_path).sub_ext('.dwc')
      make_table(contents_path)
      @table = CSV.table(@file, converters: nil)
    end

    def column_width(col)
      # FIXME: move the default width test to the SchemaEntity
      col_def = @schema.find { |c| c[:index] == col || c[:name] == col }
      default_width = col_def[:default]&.length || 0
      max_cell_width = @table.by_col[col].map { |cell| cell&.length || 0 }.max
      max_cell_width > default_width ? max_cell_width : default_width
    end

    private

    def make_table(file)
      headers = @schema.select { |c| c[:index] }
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
