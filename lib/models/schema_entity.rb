# frozen_string_literal: true

require_relative '../helpers/xml_parsable'
require_relative 'schema_attribute'

#
module DwCR
  #
  class SchemaEntity < Sequel::Model
    include XMLParsable

    ensure_unique_name = lambda do |ent, attr|
      name_taken = ent.schema_attributes_dataset.first(name: attr.name)
      attr.name = name_taken ? attr.name + '!' : attr.name
    end

    one_to_many :schema_attributes, before_add: ensure_unique_name
    one_to_many :content_files
    many_to_one :core, class: self
    one_to_many :extensions, key: :core_id, class: self

    # xml = node.css('field')
    def add_attributes_from_xml(xml)
      xml.css('field').each do |field|
        term = term_from field
        attribute = schema_attributes_dataset.first(term: term)
        vals = { term: term,
                 name: name_from(field),
                 index: index_from(field),
                 default: default_from(field) }
        attribute ||= add_schema_attribute(vals)
        attribute.update_from_xml(field, :index, :default)
      end
    end

    def add_files_from_xml(xml)
      xml.css('files').map do |file|
        add_content_file(name: name_from(file))
      end
    end

    # returns the definition for the associations
    def assocs
      # add the assoc to SchemaEntity here
      meta_assoc = [:many_to_one, :schema_entity, { class: SchemaEntity }]
      if is_core
        a = extensions.map { |extension| DwCR.association(self, extension) }
        a.unshift meta_assoc
      else
        [meta_assoc, DwCR.association(self, core)]
      end
    end

    def class_name
      name.classify
    end

    def content_headers
      schema_attributes_dataset.exclude(index: nil)
                               .order(:index)
                               .map(&:column_name)
    end

    def foreign_key
      class_name.foreign_key
    end

    def model_get
      modelname = 'DwCR::' + class_name
      modelname.constantize
    end

    def key
      schema_attributes_dataset.first(index: key_column).name.to_sym
    end

    def table_name
      name.to_sym
    end

    def data_row(row)
      hash = content_headers.zip(row).to_h
      return hash if is_core
      foreign_key = hash.delete key
      [foreign_key, hash]
    end

    def load_row(row)
        method_name = 'add_' + name.singularize
      if is_core
        instance = model_get.create(data_row(row))
      else
        core = SchemaEntity.first(is_core: true)
        foreign_key, hash = *data_row(row)
        parent_row = core.model_get.first(core.key => foreign_key)
        instance = parent_row.send(method_name, hash)
      end
      self.send(method_name, instance)
    end
  end
end
