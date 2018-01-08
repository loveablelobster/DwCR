# frozen_string_literal: true

require_relative 'schema_attribute'

#
module DwCR
  #
  class SchemaEntity < Sequel::Model
    one_to_many :schema_attributes
    one_to_many :content_files
    many_to_one :core, class: self
    one_to_many :extensions, key: :core_id, class: self

    # FIXME: relation to self for core, extensions

    def class_name
      name.classify
    end

    def content_headers
      schema_attributes_dataset.exclude(index: nil)
                               .order(:index)
                               .map(&:column_name)
    end

    def get_model
      modelname = 'DwCR::' + class_name
      modelname.constantize
    end

    def key
      schema_attributes_dataset.first(index: key_column).name.to_sym
    end

    def table_name
      name.to_sym
    end
  end
end
