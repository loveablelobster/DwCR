# frozen_string_literal: true

require 'nokogiri'

require_relative 'archive_store'
require_relative 'schema'
require_relative 'table_contents'

#
module DwCGemstone
  # meta_file: the DwCA meta.xml file
  # location: the path where the SQLite file will be stored
  class DwCGemstone
    attr_reader :schema,   # a Schema object
                :contents, # a hash { SchemaEntity.name => TableContents }
                :store     # the SQLite database instance

    def initialize(meta_file, options = { location: nil, col_lengths: false })
      @options = options
      @meta = File.open(meta_file) { |f| Nokogiri::XML(f) }
      @work_dir = File.dirname(meta_file)
      @schema = Schema.new(@meta, col_lengths: @options[:col_lengths])
      @contents = load_contents
    end

    def build_schema
      make unless @store
      @schema.entities.each do |entity|
        @store.create_table entity.name do
          primary_key :id
#             String :occurrence_id, index: true
#             String :identifier, index: {unique: true}
        end
      end
      @is_built = true
    end

    def load_tables
      build_schema unless @is_built
      # load the table contents
    end

    def make
      file = @options[:location] || @work_dir + '/' + @work_dir.split('/').last + '.db'
      puts file
      ArchiveStore.instance.connect(file)
      @store = ArchiveStore.instance.db
    end

    private

    def load_contents
      content_path = @work_dir + '/'
      contents = @schema.entities.map do |entity|
        table_contents = TableContents.new(name: entity.name,
                                           path: content_path,
                                           files: entity.contents,
                                           headers: entity.content_headers)
        entity.update(table_contents.content_lengths) if @options[:col_lengths]
        [entity.name, table_contents]
      end
      contents.to_h
    end
  end
end
