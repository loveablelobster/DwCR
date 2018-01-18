# frozen_string_literal: true

require 'csv'

#
module DwCR
  #
  class ContentFile < Sequel::Model
    many_to_one :meta_entity

    def file_name
      File.join(path, name)
    end

    # Returns an array of symbols for column names in associated
    # MetaAttribute instances that are represented in the CSV files
    # The array is sorted by the
    def content_headers
      meta_entity.meta_attributes_dataset.exclude(index: nil)
                                         .order(:index)
                                         .map(&:column_name)
    end

    def load
      CSV.open(File.join(path, name)).each do |row|
        load_row(row)
      end
    end

    private

    def load_row(row)
      if meta_entity.is_core
        entity = meta_entity.model_get.create(values_for(row))
      else
        row_vals = values_for(row)
        entity = core_row(row_vals.delete(meta_entity.key)).send(add_related, row_vals)
      end
      meta_entity.send(add_related, entity)
    end

    def core_row(foreign_key)
      meta_entity.core
                 .model_get
                 .first(meta_entity.core.key => foreign_key)
    end

    def add_related
      'add_' + meta_entity.name.singularize
    end

    # Creates a hash from a headerless CSV row
    # MetaEntity instance's :meta_attributes colum names are keys
    # the CSV row cells are values
    def values_for(row)
      content_headers.zip(row).to_h
    end
  end
end
