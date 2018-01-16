# frozen_string_literal: true

require 'csv'

require_relative '../helpers/xml_parsable'
require_relative '../models/dynamic_models'

# This module provides functionality to create a
# SQLite database from a DarwinCoreArchive
# and provides an ORM layer using http://sequel.jeremyevans.net
# Sequel::Model instances are created from the DwCA's meta.xml file
module DwCR
  # This class
  class Schema
    include XMLParsable

    attr_accessor :path
    attr_reader :core, :models

    # @path holds the directory of the DwCA file
    # @core holds the MetaEntity instance for the _core_ stanza of the DwCA
    # @models holds the generated models for the stanzas
    def initialize(path: Dir.pwd)
      @path = path
      @core = nil
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
      @core.content_files.each(&:load)
      @core.extensions.each do |extension|
        extension.content_files.each(&:load)
      end
    end

    private

    # Creates a MetaEntity instance from the xml for the stanza
    # adds MetaAttribute instances for any field defined
    def create_meta_entity_from_xml(xml)
      entity = model_from_xml(xml, MetaEntity,
                              :term, :name, :is_core, :key_column)
      entity.add_attributes_from_xml(xml)

      # add the _coreid_ attribute to any extension stanzas
      unless entity.is_core
        entity.add_meta_attribute(name: name_from(xml),
                                    index: key_column_from(xml))
      end

      entity.add_files_from_xml(xml, path: @path)
      entity
    end

    # Parses the xml for the DarwinCoreArchive
    # gets the stanzas for the _core_ and _extensions_
    def parse_meta(xml)
      validate_meta xml
      @core = create_meta_entity_from_xml(xml.css('core').first)
      xml.css('extension').each do |node|
        extn = create_meta_entity_from_xml node
        @core.add_extension(extn)
      end
    end

    # Will raise error if the XML file is not valid
    def validate_meta(xml)
      raise ArgumentError 'Multiple Core Stanzas' if xml.css('core').size > 1
    end
  end
end
