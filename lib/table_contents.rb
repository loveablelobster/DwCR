# frozen_string_literal: true

require 'csv'

#
module DwCGemstone
  # schema: a SchemaEntity
  class TableContents
    attr_reader :name, # short name of the extension, e.g. :occurrence
                :file, # full path of the .dwc file holding the full csv table
                :schema

    def initialize(path, table_schema)
      @schema = table_schema
      @file = Pathname.new(path + @schema.name.id2name + '.dwc')

      make_table(path, @schema.contents)
    end

    def content_lengths
      length_map = table.by_col.map do |col|
        attr = @schema.attribute(col.first)
        default_length = attr.length || 0
        max_length = col[1].map { |cell| cell&.length || 0 }.max
        length = max_length > default_length ? max_length : default_length
        [attr.alt_name, length]
      end
      length_map.to_h
    end

    def table
      CSV.table(@file, converters: nil)
    end

    private

    def make_table(path, files)
      CSV.open(@file, 'w',
               write_headers: true,
               headers: @schema.content_headers) do |dest|
        files.each do |f|
          CSV.open(path + f) do |source|
            source.each { |row| dest << row }
          end
        end
      end
    end
  end
end
