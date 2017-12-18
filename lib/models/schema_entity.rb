# frozen_string_literal: true

require_relative '../archive_store' # needed for sequel string and inflections
require_relative 'schema_attribute'

#
module DwCR
  def self.create_schema_entity(entity_hash)
    attributes = entity_hash.delete(:schema_attributes)
    files = entity_hash.delete(:content_files)
    entity = SchemaEntity.create(entity_hash)
    attributes.each { |a| entity.add_schema_attribute(a) }
    files.each { |f| entity.add_content_file(f) }
    entity
  end
  #
  class SchemaEntity < Sequel::Model
    one_to_many :schema_attributes
    one_to_many :content_files

    def class_name
      name.classify
    end

    def content_headers
      schema_attributes_dataset.exclude(index: nil)
                               .order(:index)
                               .map(&:column_name)
    end

    # FIXME: necessary ?
    def key
      if is_core
        key = :primary
      else
        key = :foreign
      end
      { key => schema_attributes_dataset.where(index: key_column).first.alt_name }
    end

    def table_name
      name.to_sym
    end

#     def update(attribute_lengths)
#       attribute_lengths.each do |name, length|
#         attribute(name).max_content_length = length
#       end
#     end
  end
end
