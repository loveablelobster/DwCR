# frozen_string_literal: true

require_relative '../helpers/xml_parsable'
require_relative 'schema_attribute'

#
module FindOrCreate
  def find_or_create(vals)
    create_vals = vals.merge(association_reflection[:key] => model_object.id)
    instance = first(vals) || model.create(create_vals)
    yield instance if block_given?
    instance.save
  end
end

#
module DwCR
  #
  class SchemaEntity < Sequel::Model
    include XMLParsable

    one_to_many :schema_attributes, extend: FindOrCreate
    one_to_many :content_files
    many_to_one :core, class: self
    one_to_many :extensions, key: :core_id, class: self

    def self.from_xml(xml)
      is_core = XMLParsable.core_node?(xml)
      key_col = XMLParsable.key_column(xml)
      term = xml.attributes['rowType'].value
      name = term.split('/').last.tableize
      e = create(term: term, name: name, is_core: is_core, key_column: key_col)
      e.add_attributes_from_xml(xml)
      e.add_files_from_xml(xml)
      e
    end

    # xml = node.css('field')
    def add_attributes_from_xml(xml)
      xml.css('field').each do |field|
        term = term_for field
        attribute = schema_attributes_dataset.find_or_create(term: term) do |a|
          a.name ||= unique_name(name_for(field))
          a.index ||= index_for field
          a.default ||= default_for field
        end
        attribute.update_from_xml(field, :index, :default)
      end
    end

    def add_files_from_xml(xml)
      xml.css('files').map do |file|
        add_content_file(name: name_for(file))
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

    private

    def unique_name(name)
      schema_attributes_dataset.first(name: name) ? name + '!' : name
    end
  end
end
