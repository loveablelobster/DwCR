# frozen_string_literal: true

require 'csv'

require_relative '../content_analyzer/file_set'
require_relative '../helpers/xml_parsable'
require_relative '../models/dynamic_models'
require_relative 'metaschema'

#
module DwCR
  #
  class Schema
    include XMLParsable

    def initialize(path: Dir.pwd)
      @path = path
      DwCR.create_metaschema
      require_relative '../models/schema_entity'
      require_relative '../models/schema_attribute'
      require_relative '../models/content_file'
    end

    def core
      SchemaEntity.first(is_core: true)
    end

    # gets the name of the foreign key from the core entity
    def foreign_key_def
      [core.class_name.foreign_key, core.table_name]
    end

    def load_schema(meta = File.join(@path, 'meta.xml'))
      xml = File.open(meta) { |f| Nokogiri::XML(f) }
      parse_meta(xml)
    end

    # schema option:
    # - :col_type => true   # will set column types other than string
    # - :col_length => true # will set lengths for (string) columns
    def create_schema(**schema_options)
      update_schema(schema_options)
      SchemaEntity.each do |entity|
        create_schema_table(entity)
      end
      load_models
    end

    def update_schema(schema_options)
      return unless schema_options
      schema_options.select! { |_k, v| v == true }
      modifiers = schema_options.keys
      SchemaEntity.each do |entity|
        files = entity.content_files
                      .map { |file| File.join(@path, file.name) }
        col_params = FileSet.new(files, modifiers).columns
        col_params.each do |cp|
          column = entity.schema_attributes_dataset.first(index: cp[:index])
          cp[:type] = cp[:type]&.to_s&.underscore
          modifiers.each { |m| column.send(m.id2name + '=', cp[m]) if cp[m] }
          column.save
        end
      end
    end

    def load_contents
      load_files(@path)
    end

    private

    def parse_meta(xml)
      raise ArgumentError 'Multiple Core Stanzas' if xml.css('core').size > 1
      core = create_schema_entity_from_xml(xml.css('core').first)
      xml.css('extension').each do |node|
        extn = create_schema_entity_from_xml node
        core.add_extension(extn)
        extn.add_schema_attribute(name: name_from(node),
                                  index: key_column_from(node))
      end
    end

    def create_schema_entity_from_xml(xml)
      entity = model_from_xml(xml, SchemaEntity,
                              :term, :name, :is_core, :key_column)
      entity.add_attributes_from_xml(xml)
      entity.add_files_from_xml(xml)
      entity
    end

    # Create the tables for the DwCA Schema
    def create_schema_table(entity)
      core_table = foreign_key_def
      Sequel::Model.db.create_table? entity.table_name do
        primary_key :id
        foreign_key :schema_entity_id, :schema_entities
        foreign_key *core_table unless entity.is_core
        entity.schema_attributes.each do |a|
          # skip the foreign_key of the extension
          next if a.column_name == entity.key && !entity.is_core
          column(*a.column_params)
        end
      end
    end

    # Create the Dynamic Models
    def load_models
      SchemaEntity.each do |entity|
        entity_model = DwCR.create_model(entity.class_name,
                                         entity.table_name,
                                         *entity.assocs)
        # associate here
        SchemaEntity.associate(:one_to_many,
                               entity.table_name,
                               class: entity_model)
      end
    end

    # Load Table Contents
    def load_files(path)
      core.content_files.each { |file| file.load_file(path) }
      core.extensions.each do |extension|
        extension.content_files.each { |file| file.load_file(path) }
      end
    end
  end
end
