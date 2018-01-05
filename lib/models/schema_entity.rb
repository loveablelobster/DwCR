# frozen_string_literal: true

require_relative 'schema_attribute'

#
module DwCR
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

    def get_model
      modelname = 'DwCR::' + class_name
      modelname.constantize
    end

    def key
      schema_attributes_dataset.first(index: key_column).alt_name.to_sym
    end

    def table_name
      name.to_sym
    end
  end
end
