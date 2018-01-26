# frozen_string_literal: true

require 'csv'

require_relative '../models/dynamic_models'
require_relative '../helpers/xml_parsable'
#
module DwCR
  # This class
  class Schema # FIXME: rename Builder
    attr_accessor :path
    attr_reader :archive, :models

    # @path holds the directory of the DwCA file
    # @core holds the MetaEntity instance for the _core_ node of the DwCA
    # @models holds the generated models for the nodes
    def initialize(path: Dir.pwd)
      @path = path
      @archive = MetaArchive.create(path: @path)
      @models = nil
    end

    # Loads and parses the given _meta.xml_ file
    # gets the nodes for the _core_ and _extensions_
    # if no _Meta.xml_ is given, will try to load the _meta.xml_ file in _@path_
    def load_meta(meta = nil)
      meta ||= File.join(@path, 'meta.xml')
      xml = File.open(meta) { |f| Nokogiri::XML(f) }
      # FIXME: add rescue
      XMLParsable.validate_meta xml
      @archive.load_entities_from xml
    end

    # Creates the database schema for the DwCA nodes
    # _schema_options_:
    # - +type:+ +true+ or +false+
    # - +length:+ +true+ or +false+
    # if schema_options are given, the schema will be updated
    # based on the DwCA files actual content,
    # analysing each column for type and length
    def create_schema(**schema_options)
      DwCR.update_schema(@archive, schema_options)
      @archive.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
      @models = DwCR.load_models(@archive)
    end
  end
end
