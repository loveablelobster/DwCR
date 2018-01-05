# frozen_string_literal: true

require_relative '../content_analyzer/file_set'
require_relative '../meta_parser'
require_relative '../models/dynamic_models'
require_relative 'loadable'
require_relative 'metaschema'

#
module DwCR
  #
  class Schema
    include Loadable

    def initialize
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

    def load_schema(meta)
      xml = File.open(meta) { |f| Nokogiri::XML(f) }
      DwCR.parse_meta(xml).each do |entity_hash|
        attributes = entity_hash.delete(:schema_attributes)
        files = entity_hash.delete(:content_files)
        entity = SchemaEntity.create(entity_hash)
        attributes.each { |a| entity.add_schema_attribute(a) }
        files.each { |f| entity.add_content_file(f) }
      end
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
        # FIXME: path!
        files = entity.content_files
                      .map { |file| Dir.pwd + '/spec/files/' + file.name }
        col_params = FileSet.new(files, modifiers).columns
        col_params.each do |cp|
          column = entity.schema_attributes_dataset.first(index: cp[:index])
          cp[:type] = cp[:type]&.to_s&.underscore
          modifiers.each { |m| column.send((m.id2name + '=').to_sym, cp[m]) if cp[m] }
          column.save
        end
      end
    end

    private

    # Create the tables for the DwCA Schema
    def create_schema_table(entity, foreign_key)
      Sequel::Model.db.create_table? entity.table_name do
        primary_key :id
        entity.schema_attributes.each { |a| column(*a.column_params) }
        next if entity.is_core
        column foreign_key, :integer
      end
    end

    def update_schema_entity()

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
  end
end
