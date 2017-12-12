# frozen_string_literal: true

require 'csv'

#
module DwCR
  # name: Symbol
  class TableContents
    attr_reader :name, # short name of the extension, e.g. :occurrence
                :file, # full path of the .dwc file holding the full csv table
                :schema

    def initialize(name:, path:, files:, headers:) # use headers instead
      @name = name
      @headers = headers
      @file = Pathname.new(path + @name.id2name + '.dwc')
      make_table(path, files)
    end

    def content_lengths
      lengths = table.by_col.map do |col|
        col[1].map { |cell| cell&.length || 0 }.max
      end
      @headers.zip(lengths).to_h
    end

    def table
      CSV.table(@file, converters: nil)
    end

    private

    def make_table(path, files)
      CSV.open(@file, 'w',
               write_headers: true,
               headers: @headers) do |dest|
        files.each do |f|
          CSV.open(path + f) do |source|
            source.each { |row| dest << row }
          end
        end
      end
    end
  end
end
