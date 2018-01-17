# frozen_string_literal: true

require 'csv'

require_relative '../models/dynamic_models'

#
module DwCR
  # This class
  class Schema
    attr_accessor :path
    attr_reader :archive, :models

    # @path holds the directory of the DwCA file
    # @core holds the MetaEntity instance for the _core_ stanza of the DwCA
    # @models holds the generated models for the stanzas
    def initialize(path: Dir.pwd)
      @path = path
      @archive = nil
      @models = nil
    end

    # Loads the _meta.xml_ file in _@path_
    # calls #parse_meta(xml)
    def load_schema(meta = File.join(@path, 'meta.xml'))
      parse_meta(File.open(meta) { |f| Nokogiri::XML(f) })
    end

    # Creates the database schema for the DwCA stanzas
    # _schema_options_:
    # - +type:+ +true+ or +false+
    # - +length:+ +true+ or +false+
    # if schema_options are given, the schema will be updated
    # based on the DwCA files actual content,
    # analysing each column for type and length
    def create_schema(**schema_options)
      update_schema(schema_options)
      MetaEntity.each do |entity|
        DwCR.create_schema_table(entity)
      end
      @models = DwCR.load_models
    end

    # Updates all MetaAttribute instances
    # with parameters from files in ContentFile
    # _schema_options_: a Hash with attribute names as keys and boolean values
    # <tt>{ :type => true, :length => true }</tt>
    # updates any attribute given as key where value is _true_
    def update_schema(schema_options)
      return unless schema_options

      # FIXME: throw an error if schema is not built

      schema_options.select! { |_k, v| v == true }
      modifiers = schema_options.keys
      MetaEntity.each { |entity| entity.update_with(modifiers) }
    end

    # Loads the contents of all associated CSV files into the shema tables
    def load_contents
      @archive.core.content_files.each(&:load)
      @archive.core.extensions.each do |extension|
        extension.content_files.each(&:load)
      end
    end

    private

    # Parses the xml for the DarwinCoreArchive
    # gets the stanzas for the _core_ and _extensions_
    def parse_meta(xml)
      validate_meta xml
      @archive = MetaArchive.create(path: @path)
      @archive.load_entities_from xml
    end

    # Will raise error if the XML file is not valid
    def validate_meta(xml)
      raise ArgumentError 'Multiple Core Stanzas' if xml.css('core').size > 1
    end
  end
end
