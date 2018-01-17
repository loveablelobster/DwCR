# frozen_string_literal: true

require_relative '../content_analyzer/file_set'
require_relative '../helpers/xml_parsable'
require_relative 'meta_entity'

#
module DwCR
  #
  class MetaArchive < Sequel::Model
    include XMLParsable

    one_to_many :meta_entities
    one_to_one :core, class: DwCR::MetaEntity, key: :coreid
  end
end
