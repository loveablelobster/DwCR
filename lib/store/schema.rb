# frozen_string_literal: true

require 'csv'

require_relative '../content_analyzer/file_set'
require_relative '../models/dynamic_models'
require_relative 'metaschema'

#
module DwCR
  #
  class Schema
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

    def extensions
      SchemaEntity.where(is_core: false)
    end

    # gets the name of the foreign key from the core entity
    def foreign_key
      core.class_name.foreign_key
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
        create_schema_table(entity, foreign_key)
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
          modifiers.each { |m| column.send((m.id2name + '=').to_sym, cp[m]) if cp[m] }
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
      core = DwCR::SchemaEntity.from_xml(xml.css('core').first)
      xml.css('extension').each do |node|
        extn = DwCR::SchemaEntity.from_xml node
        core.add_extension(extn)
        key = node.css('coreid').first
        extn.add_schema_attribute(name: key.name,
                                  index: key.attributes['index']&.value&.to_i)
      end
    end

    # Create the tables for the DwCA Schema
    def create_schema_table(entity, foreign_key)
      Sequel::Model.db.create_table? entity.table_name do
        primary_key :id
        entity.schema_attributes.each do |a|
          # skip the foreign_key of the extension
          next if a.column_name == entity.key && !entity.is_core

          column(*a.column_params)
        end
        next if entity.is_core
        column foreign_key, :integer, index: true
      end
    end

    # Create the Dynamic Models
    def association(left_entity, right_entity)
      options = { class: right_entity.class_name, class_namespace: 'DwCR' }
      if left_entity.is_core
        options[:key] = "#{left_entity.name.singularize}_id".to_sym
        [:one_to_many, right_entity.table_name, options]
      else
        options[:key] = "#{right_entity.name.singularize}_id".to_sym
        [:many_to_one, right_entity.name.singularize.to_sym, options]
      end
    end

    def load_models
      core = SchemaEntity.first(is_core: true)
      extensions = SchemaEntity.where(is_core: false)
      SchemaEntity.each do |entity|
        assocs = if entity.is_core
                   extensions.map { |extension| association(entity, extension) }
                 else
                   [association(entity, core)]
                 end
        DwCR.create_model(entity.class_name, entity.table_name, *assocs)
      end
    end

    # Load Table Contents
    def load_files(path)
      SchemaEntity.dataset.order(Sequel.desc(:is_core)).to_a.each do |entity|
        headers = entity.content_headers
        entity.content_files.each do |file|
          CSV.open(File.join(path, file.name)).each do |row|
            data_row = headers.zip(row).to_h

            # FIXME: SchemaEntity#load_row should handle below if clause

            if entity.is_core
              entity.model_get.create(data_row)
            else
              key = data_row.delete(entity.key) # get the 'coreid' and remove it
              core_instance = core.model_get
                                  .first(core.key => key)
              method_name = 'add_' + entity.name.singularize
              core_instance.send(method_name, data_row)
            end
          end
        end
      end
    end
  end
end
