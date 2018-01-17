# frozen_string_literal: true

require_relative '../content_analyzer/file_set'
require_relative '../helpers/xml_parsable'

#
module DwCR
  #
  class MetaEntity < Sequel::Model
    include XMLParsable

    ensure_unique_name = lambda do |ent, attr|
      name_taken = ent.meta_attributes_dataset.first(name: attr.name)
      attr.name = name_taken ? attr.name + '!' : attr.name
    end

    many_to_one :meta_archive
    one_to_many :meta_attributes, before_add: ensure_unique_name
    one_to_many :content_files
    many_to_one :core, class: self
    one_to_many :extensions, key: :core_id, class: self

    # xml = node.css('field')
    def add_attributes_from_xml(xml)
      # add the _coreid_ attribute to any extension stanzas
      unless is_core
        add_meta_attribute(name: name_from(xml),
                           index: key_column_from(xml))
      end

      xml.css('field').each do |field|
        term = term_from field
        attribute = meta_attributes_dataset.first(term: term)
        vals = { term: term,
                 name: name_from(field),
                 index: index_from(field),
                 default: default_from(field) }
        attribute ||= add_meta_attribute(vals)
        attribute.update_from_xml(field, :index, :default)
      end
    end

    def add_files_from_xml(xml, path: nil)
      xml.css('files').map do |file|
        add_content_file(name: name_from(file), path: path)
      end
    end

    # returns the definition for the associations
    def assocs
      # add the assoc to MetaEntity here
      meta_assoc = [:many_to_one, :meta_entity, { class: MetaEntity }]
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
      meta_attributes_dataset.exclude(index: nil)
                             .order(:index)
                             .map(&:column_name)
    end

    # Returns an array of full filenames with path
    def files
      content_files.map(&:file_name)
    end

    def foreign_key
      class_name.foreign_key
    end

    def model_get
      modelname = 'DwCR::' + class_name
      modelname.constantize
    end

    def key
      meta_attributes_dataset.first(index: key_column).name.to_sym
    end

    def table_name
      name.to_sym
    end

    def update_with(modifiers)
      FileSet.new(files, modifiers).columns.each do |cp|
        column = meta_attributes_dataset.first(index: cp[:index])
        modifiers.each { |m| column.send(m.id2name + '=', cp[m]) if cp[m] }
        column.save
      end
    end

    def load_row(row)
      if is_core
        instance = model_get.create(data_row(row))
      else
        core = MetaEntity.first(is_core: true)
        foreign_key, hash = *data_row(row)
        parent_row = core.model_get.first(core.key => foreign_key)
        instance = parent_row.send(add_related, hash)
      end
      send(add_related, instance)
    end

    private

    # Returns the name for the method to add an instance through an association
    def add_related
      'add_' + name.singularize
    end

    def data_row(row)
      hash = content_headers.zip(row).to_h
      return hash if is_core
      foreign_key = hash.delete key
      [foreign_key, hash]
    end
  end
end
