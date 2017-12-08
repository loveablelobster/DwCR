# frozen_string_literal: true

require 'nokogiri'

require_relative 'schema'
require_relative 'table_contents'

#
module DwCGemstone
  #
  class DwCGemstone
    attr_reader :schema,  # a Schema object
                :contents # a hash { SchemaEntity.name => TableContents }

    def initialize(meta_file, options = { col_lengths: false })
      @options = options
      @meta = File.open(meta_file) { |f| Nokogiri::XML(f) }
      @work_dir = File.dirname(meta_file) + '/'
      @schema = Schema.new(@meta, col_lengths: @options[:col_lengths])
      @contents = load_contents
    end

    private

    def load_contents
      contents = @schema.entities.map do |entity|
        table_contents = TableContents.new(@work_dir, entity)
        entity.update(table_contents.content_lengths) if @options[:col_lengths]
        [entity.name, table_contents]
      end
      contents.to_h
    end
  end
end
