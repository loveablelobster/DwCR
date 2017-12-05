# frozen_string_literal: true

require 'nokogiri'

require_relative 'schema_entity'

#
module DwCGemstone
  #
  class DwCGemstone
    def initialize(meta_file)
      @meta = File.open(meta_file) { |f| Nokogiri::XML(f) }
      @work_dir = File.dirname(meta_file)
      @schema_entities = []
      @table_contents = []
      load_core
      load_extensions
    end

    private

    def load_core
      core_entity = SchemaEntity.new(@meta.css('core').first)
      TableContents.new(@work_dir, core_entity)
    end

    def load_extensions
      @meta.css('extension').each do |ext|
        entity = SchemaEntity.new(ext)
        @schema_entities << entity
        @table_contents << TableContents.new(@work_dir, entity)
      end
    end
  end
end
