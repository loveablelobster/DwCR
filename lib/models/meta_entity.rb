# frozen_string_literal: true

require_relative '../content_analyzer/file_set'
require_relative '../helpers/xml_parsable'

#
module DwCR
  # This class represents _core_ or _extension_ stanzas in DarwinCoreArchive
  # * +name+: the name for the stanza
  #   default: pluralized term without namespace in underscore (snake case) form
  # * +term+: the full term (a uri), including namespace for the stanza
  #   see http://rs.tdwg.org/dwc/terms/index.htm
  # * +is_core+:
  #   _true_ if the stanza is the core stanza of the DarwinCoreArchive,
  #   _false_ otherwise
  # * +key_column+: the column in the stanza representing
  #   the primary key of the core stanza or
  #   the foreign key in am extension stanza
  # * +fields_enclosed_by+: directive to form CSV in :content_files
  #   default: '&quot;'
  # * +fields_terminated_by+: fieldsTerminatedBy=","
  # * +lines_terminated_by+: linesTerminatedBy="\r\n"
  # * *#meta_archive*:
  #   the MetaArchive the MetaEntity belongs to
  # * *#meta_attributes*:
  #   MetaAttribute instances associated with the MetaEntity
  # * *#content_files*:
  #   ContentFile instances associated with the MetaEntity
  # * *#core*:
  #   if the MetaEntity is an _extension_
  #   returns the MetaEntity representing the _core_ stanza
  #   nil otherwise
  # * *#extensions*:
  #   if the MetaEntity is the _core_ stanza
  #   returns any MetaEntity instances representing _extension_ stanzas
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

    def before_create
      self.name ||= term&.split('/')&.last&.tableize
      super
    end

    # Creates a MetaAttribute instance from an xml node (_field_)
    # given that the instance has not been previously defined
    # if an instance has been previously defined, it will be updated
    def add_attribute_from(xml)
      attribute = meta_attributes_dataset.first(term: term_from(xml))
      attribute ||= add_meta_attribute(values_from(xml,
                                                   :term,
                                                   :name,
                                                   :index,
                                                   :default))
      attribute.update_from(xml, :index, :default)
    end

    # Creates a ContentFile instance from an xml node (_file_)
    # a +path+ can be given to add files from arbitrary locations
    def add_file_from(xml, path: nil)
      add_content_file(name: name_from(xml), path: path)
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
