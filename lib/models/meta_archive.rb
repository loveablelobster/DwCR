# frozen_string_literal: true

require_relative '../content_analyzer/file_set'
require_relative '../helpers/xml_parsable'

#
module DwCR
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
  #   default: 'http://rs.tdwg.org/dwc/text/ http://rs.tdwg.org/dwc/text/tdwg_dwc_text.xsd'
  class MetaArchive < Sequel::Model
    include XMLParsable

    one_to_many :meta_entities
    many_to_one :core, class: 'MetaEntity',
                       class_namespace: 'DwCR', key: :core_id

    def before_create
      self.name ||= path&.split('/')&.last
      super
    end

    # methods to add records to :meta_entities association form xml

    # Creates a MetaEntity instance from xml node (_core_ or _extension_)
    # adds MetaAttribute instances for any field defined
    def add_meta_entity_from(xml)
      entity = add_meta_entity(value_hash(xml,
                                          :term, :name, :is_core, :key_column))
      entity.add_attributes_from_xml(xml)
      entity.add_files_from_xml(xml, path: path)
      entity
    end

    # Gets _core_ and _extension_ nodes from the xml
    # calls #add_meta_entity_from(xml) to create
    # MetaEntity instances to the MetaArchive for every node
    def load_entities_from(xml)
      self.core = add_meta_entity_from xml.css('core').first
      xml.css('extension').each do |node|
        extn = add_meta_entity_from node
        core.add_extension(extn)
      end
      save
    end
  end
end
