# frozen_string_literal: true

#
module DwCR
  #
  module Metaschema
    # This class represents the DarwinCoreArchive's _meta.xml_ file
    # * +name+: the name for the DarwinCoreArchive
    #   the default is the directory name given in the path
    # * +path+: the full path of the directory of the DarwinCoreArchives
    # * +xmlns+: the XML Namespace
    #   default: 'http://rs.tdwg.org/dwc/text/'
    # * +xmlns__xs+: the schema namespace prefix (xmlns:xs),
    #   default: 'http://www.w3.org/2001/XMLSchema'
    # * +xmln__xsi+: schema instance namespace prefix (xmln:xsi),
    #   default: 'http://www.w3.org/2001/XMLSchema-instance'
    # * +xsi__schema_location+ (xsi:schemaLocation)
    #   default: 'http://rs.tdwg.org/dwc/text/
    #             http://rs.tdwg.org/dwc/text/tdwg_dwc_text.xsd'
    # * *#entities*:
    #   the associated Entity objects
    # * *#core*:
    #   the associated Entity object that is the core node in the DwCA
    class Archive < Sequel::Model
      include XMLParsable

      ensure_core = lambda do |entity|
        entity.is_core = true
      end

      ensure_not_core = lambda do |ent, attr|
        raise 'adding an extension without a core' unless ent.core
        attr.is_core = false
        attr.core = ent.core
      end

      one_to_many :entities
      many_to_one :core, class: 'Entity',
                         class_namespace: 'DwCR::Metaschema',
                         key: :core_id,
                         setter: ensure_core
      one_to_many :extensions, class: 'Entity',
                               class_namespace: 'DwCR::Metaschema',
                               key: :archive_id,
                               conditions: { is_core: false },
                               before_add: ensure_not_core

      # Methods to add records to the :entities association form xml

      # Gets _core_ and _extension_ nodes from the xml
      # calls #add_entity_from(xml) to create
      # Entity instances to the Archive for every node
      # adds the foreign key field (_coreid_) to any _extension_
      def load_nodes_from(xml)
        self.core = add_entity_from xml.css('core').first
        core.save
        xml.css('extension').each do |node|
          extn = add_entity_from node
          extn.add_attribute(name: 'coreid', index: index_from(node))
          add_extension(extn)
        end
        save
      end

      private

      # Sequel Model hook that creates a default +name+
      # from the +term+ if present
      def before_create
        self.name ||= path&.split('/')&.last
        super
      end

      # Creates a Entity instance from xml node (_core_ or _extension_)
      # adds Attribute instances for any _field_ given
      # adds ContentFile instances for any child node of _files_
      def add_entity_from(xml)
        entity = add_entity(values_from(xml, :term, :key_column))
        xml.css('field').each { |field| entity.add_attribute_from(field) }
        entity.add_files_from(xml, path: path)
        entity
      end
    end
  end
end
