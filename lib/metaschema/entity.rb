# frozen_string_literal: true

require_relative 'xml_parsable'

#
module DwCR
  #
  module Metaschema
    # This class represents _core_ or _extension_ nodes in DarwinCoreArchive
    # * +name+: the name for the node
    #   default: pluralized term without namespace
    #   in underscore (snake case) form
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
    # * *#archive*:
    #   the Archive instance the Entity instance belongs to
    # * *#attributes*:
    #   Attribute instances associated with the Entity
    # * *#content_files*:
    #   ContentFile instances associated with the Entity
    # * *#core*:
    #   if the Entity instance is an _extension_
    #   returns the Entity instance representing the _core_ node
    #   nil otherwise
    # * *#extensions*:
    #   if the Entity instance is the _core_ node
    #   returns any Entity instances representing _extension_ nodes
    class Entity < Sequel::Model
      include XMLParsable

      ensure_not_core = lambda do |ent, attr|
        e = 'extensions must be associated with a core'
        attr.is_core = false
        raise ArgumentError, e unless ent.is_core
        attr.archive = ent.archive
      end

      ensure_path = lambda do |ent, attr|
        attr.path ||= ent.archive.path
      end

      ensure_unique_name = lambda do |ent, attr|
        attr.name ||= attr.term&.split('/')&.last&.underscore
        name_taken = ent.attributes_dataset.first(name: attr.name)
        attr.name = name_taken ? attr.name + '!' : attr.name
      end

      many_to_one :archive
      one_to_many :attributes, before_add: ensure_unique_name
      one_to_many :content_files, before_add: ensure_path
      many_to_one :core, class: self
      one_to_many :extensions, key: :core_id, class: self,
                               before_add: ensure_not_core

      # Returns a string with Entity instance's singularized name in camelcase
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
        loaded_files = content_files_dataset.where(is_loaded: true)
        return true if loaded_files.count == content_files.size
        loaded_files.empty? ? false : loaded_files.map(&:file_name)
      end

      # Returns a symbol based on the Entity instance's foreign key name
      def foreign_key
        class_name.foreign_key.to_sym
      end

      # Returns a symbol for the +name+ of
      # the associated Attribute instance that is the key_column
      # in the DarwinCoreArchive node the Entity represents
      def key
        attributes_dataset.first(index: key_column).name.to_sym
      end

      # Returns an array of parameters for all associations of the Sequel::Model
      # in the DarwinCoreArchive schema that the Entity represents
      # each set of parameters is an array
      # <tt>[association_type, association_name, options]</tt>
      # that can be splattet as arguments into
      # Sequel::Model::Associations::ClassMethods#associate
      def model_associations
        # add the assoc to Entity here
        meta_assoc = [:many_to_one, :entity, { class: Entity }]
        if is_core
          a = extensions.map { |extension| association_with(extension) }
          a.unshift meta_assoc
        else
          [meta_assoc, association_with(core)]
        end
      end

      # Returns the constant with module name for the Entity instance
      # this is the constant of the Sequel::Model
      # in the DarwinCoreArchive schema
      def model_get
        modelname = 'DwCR::' + class_name
        modelname.constantize
      end

      # Returns a symbol for the pluralzid +name+ that is
      # the name of the table in the DarwinCoreArchive schema
      def table_name
        name.tableize.to_sym
      end

      # Analyzes the Entity instance's content_files
      # for any parameters given as modifiers and updates the
      # asssociated _attributes_ with the new values
      # * _:length_ or _'length'_
      #   will update the Attribute instances' +max_content_length+
      # * _:type_ or _'type'_
      #   will update the Attribute instances' +type+ attributes
      def update_attributes!(*modifiers)
        DwCAContentAnalyzer::FileSet.new(files, modifiers).columns.each do |cp|
          column = attributes_dataset.first(index: cp[:index])
          modifiers.each { |m| column.send(m.to_s + '=', cp[m]) }
          column.save
        end
      end

      # Methods to add records to the :attributes and
      # :content_files associations form xml

      # Creates a Attribute instance from an xml node (_field_)
      # given that the instance has not been previously defined
      # if an instance has been previously defined, it will be updated
      def add_attribute_from(xml)
        attribute = attributes_dataset.first(term: term_from(xml))
        attribute ||= add_attribute(values_from(xml,
                                                     :term,
                                                     :index,
                                                     :default))
        attribute.update_from(xml, :index, :default)
      end

      # Creates a ContentFile instance from an xml node (_file_)
      # a +path+ can be given to add files from arbitrary directories
      # +name+ is parsed from the _location_ node
      def add_files_from(xml, path: nil)
        files_from(xml).each { |file| add_content_file(name: file, path: path) }
      end

      private

      # Sequel Model hook that creates a default +name+ from the +term+
      def before_create
        e = 'Entity instances need to belong to a Archive'
        raise ArgumentError, e unless archive
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
end
