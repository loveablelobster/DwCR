# frozen_string_literal: true

require 'csv'

require_relative '../models/dynamic_models'

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
    # if none is given, will try to load the _meta.xml_ file in _@path_
    def load_meta(meta = nil)
      meta ||= File.join(@path, 'meta.xml')
      parse_meta(File.open(meta) { |f| Nokogiri::XML(f) })
    end

    # Creates the database schema for the DwCA nodes
    # _schema_options_:
    # - +type:+ +true+ or +false+
    # - +length:+ +true+ or +false+
    # if schema_options are given, the schema will be updated
    # based on the DwCA files actual content,
    # analysing each column for type and length
    def create_schema(**schema_options)
      update_schema(schema_options)
      @archive.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
      @models = DwCR.load_models(@archive)
    end

    # Updates all MetaAttribute instances
    # with parameters from files in ContentFile
    # _schema_options_: a Hash with attribute names as keys and boolean values
    # <tt>{ :type => true, :length => true }</tt>
    # updates any attribute given as key where value is _true_
    def update_schema(options)
      return if options.empty?

      # FIXME: throw an error if schema is not built

      options.select! { |_k, v| v == true }
      @archive.meta_entities
              .each { |entity| entity.update_meta_attributes!(*options.keys) }
    end

    # Loads the contents of all associated CSV files into the shema tables
    def load_contents
      @archive.core.content_files.each(&:load)
      @archive.extensions.each do |extension|
        extension.content_files.each(&:load)
      end
    end

    private

    # Parses the xml for the DarwinCoreArchive
    # gets the nodes for the _core_ and _extensions_
    def parse_meta(xml)
      validate_meta xml
      @archive.load_entities_from xml
    end

    # Will raise error if the XML file is not valid
    def validate_meta(xml)
      raise ArgumentError 'Multiple Core nodes' if xml.css('core').size > 1
    end
  end
end
