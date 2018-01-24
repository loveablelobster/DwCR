# frozen_string_literal: true

require_relative '../content_analyzer/file_set'
require_relative '../helpers/xml_parsable'

#
module DwCR
  # This class represents _core_ or _extension_ nodes in DarwinCoreArchive
  # * +name+: the name for the node
  #   default: pluralized term without namespace in underscore (snake case) form
  # * +term+: the full term (a uri), including namespace for the node
  #   see http://rs.tdwg.org/dwc/terms/index.htm
  # * +is_core+:
  #   _true_ if the node is the core node of the DarwinCoreArchive,
  #   _false_ otherwise
  # * +key_column+: the column in the node representing
  #   the primary key of the core node or
  #   the foreign key in am extension node
  # * +fields_enclosed_by+: directive to form CSV in :content_files
  #   default: '&quot;'
  # * +fields_terminated_by+: fieldsTerminatedBy=","
  # * +lines_terminated_by+: linesTerminatedBy="\r\n"
  # * *#meta_archive*:
  #   the MetaArchive instance the MetaEntity instance belongs to
  # * *#meta_attributes*:
  #   MetaAttribute instances associated with the MetaEntity
  # * *#content_files*:
  #   ContentFile instances associated with the MetaEntity
  # * *#core*:
  #   if the MetaEntity instance is an _extension_
  #   returns the MetaEntity instance representing the _core_ node
  #   nil otherwise
  # * *#extensions*:
  #   if the MetaEntity instance is the _core_ node
  #   returns any MetaEntity instances representing _extension_ nodes
  class MetaEntity < Sequel::Model
    include XMLParsable

    ensure_not_core = lambda do |ent, attr|
      attr.is_core = false
      attr.meta_archive_id = ent.meta_archive_id
    end

    ensure_unique_name = lambda do |ent, attr|
      attr.name ||= attr.term&.split('/')&.last&.underscore
      name_taken = ent.meta_attributes_dataset.first(name: attr.name)
      attr.name = name_taken ? attr.name + '!' : attr.name
    end

    many_to_one :meta_archive
    one_to_many :meta_attributes, before_add: ensure_unique_name
    one_to_many :content_files
    many_to_one :core, class: self
    one_to_many :extensions, key: :core_id, class: self, before_add: ensure_not_core

    # Returns a string with MetaEntity instance's singularized name in camelcase
    # this is the name of the Sequel::Model in the DarwinCoreArchive schema
    def class_name
      name.classify
    end

    # Returns an array of full filenames with path
    # for all associated ContentFile instances
    def files
      content_files.map(&:file_name)
    end

    # Returns *true* if all _content_files_ have been loaded,
    # _false_ otherwise
    def loaded?
      content_files_dataset.where(is_loaded: false).empty?
    end

    # Returns a symbol based on the MetaEntity instance's foreign key name
    def foreign_key
      class_name.foreign_key.to_sym
    end

    # Returns a symbol for the +name+ of
    # the associated MetaAttribute instance that is the key_column
    # in the DarwinCoreArchive node the MetaEntity represents
    def key
      meta_attributes_dataset.first(index: key_column).name.to_sym
    end

    # Returns an array of parameters for all associations of the Sequel::Model
    # in the DarwinCoreArchive schema that the MetaEntity represents
    # each set of parameters is an array
    # <tt>[association_type, association_name, options]</tt>
    # that can be splattet as arguments into
    # Sequel::Model::Associations::ClassMethods#associate
    def model_associations
      # add the assoc to MetaEntity here
      meta_assoc = [:many_to_one, :meta_entity, { class: MetaEntity }]
      if is_core
        a = extensions.map { |extension| association_with(extension) }
        a.unshift meta_assoc
      else
        [meta_assoc, association_with(core)]
      end
    end

    # Returns the constant with module name for the MetaEntity instance
    # this is the constant of the Sequel::Model in the DarwinCoreArchive schema
    def model_get
      modelname = 'DwCR::' + class_name
      modelname.constantize
    end

    # Returns a symbol for the pluralzid +name+ that is
    # the name of the table in the DarwinCoreArchive schema
    def table_name
      name.tableize.to_sym
    end

    # Analyzes the MetaEntity instance's content_files
    # for any parameters given as modifiers and updates the
    # asssociated _meta_attributes_ with the new values
    # * _:length_ or _'length'_
    #   will update the MetaAttribute instances' +max_content_length+ attributes
    # * _:type_ or _'type'_
    #   will update the MetaAttribute instances' +type+ attributes
    def update_meta_attributes!(*modifiers)
      FileSet.new(files, modifiers).columns.each do |cp|
        column = meta_attributes_dataset.first(index: cp[:index])
        modifiers.each { |m| column.send(m.to_s + '=', cp[m]) }
        column.save
      end
    end

    # Methods to add records to the :meta_attributes and
    # :content_files associations form xml

    # Creates a MetaAttribute instance from an xml node (_field_)
    # given that the instance has not been previously defined
    # if an instance has been previously defined, it will be updated
    def add_attribute_from(xml)
      attribute = meta_attributes_dataset.first(term: term_from(xml))
      attribute ||= add_meta_attribute(values_from(xml,
                                                   :term,
                                                   :index,
                                                   :default))
      attribute.update_from(xml, :index, :default)
    end

    # Creates a ContentFile instance from an xml node (_file_)
    # a +path+ can be given to add files from arbitrary directories
    # +name+ is parsed from the _location_ node
    def add_file_from(xml, path: nil)
      add_content_file(name: name_from(xml), path: path)
    end

    private

    # Sequel Model hook that creates a default +name+ from the +term+ if present
    def before_create
      self.name ||= term&.split('/')&.last&.underscore
      super
    end

    # Returns an array that can be splattet as arguments into the
    # Sequel::Model::Associations::ClassMethods#associate method:
    # <tt>[association_type, association_name, options]</tt>
    def association_with(entity)
      options = { class: entity.class_name, class_namespace: 'DwCR' }
      if is_core
        options[:key] = foreign_key
        [:one_to_many, entity.table_name, options]
      else
        options[:key] = entity.foreign_key
        [:many_to_one, entity.name.singularize.to_sym, options]
      end
    end
  end
end
