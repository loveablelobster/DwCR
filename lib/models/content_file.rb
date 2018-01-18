# frozen_string_literal: true

require 'csv'

#
module DwCR
  # This class represents _location_ nodes (children of the _files_ nodes)
  # in DarwinCoreArchive, which represent csv files associated with a
  # _core_ or _extension_ node
  # * +name+:
  #   the basename of the file with extension (normally .csv)
  # * +path+:
  #   the directory path where the file is located
  #   set this attribute to load content files from arbitrary directories
  # * +is_loaded+:
  #   a flag that is set to +true+ when the ContentFile instance's
  #   contents have been loaded from the CSV file into the database
  # * *#meta_entity*:
  #   the MetaEntity instance the ContentFile instance belongs to
  class ContentFile < Sequel::Model
    many_to_one :meta_entity

    # Returns the full file name including the path
    def file_name
      File.join(path, name)
    end

    # Returns an array of symbols for column names for each column in the
    # (headerless) CSV file specified in the +file+ attribute
    # the array is mapped from the ContentFile instance's parent MetaEntity
    # instance's MetaAttribute instances that have an +index+
    # The array is sorted by the +index+
    def content_headers
      meta_entity.meta_attributes_dataset.exclude(index: nil)
                                         .order(:index)
                                         .map(&:column_name)
    end

    #
    def load
      return if is_loaded
      CSV.foreach(file_name) { |row| insert_row(row) }
      self.is_loaded = true
      save
    end

    #
    # if this is called on a _core_ instance, this will also destroy any
    # dependant _extension_ records!
    def unload!
      return unless is_loaded
      CSV.foreach(file_name) { |row| delete_row(row) }
      self.is_loaded = false
      save
    end

    private

    def delete_row(row)
      row_vals = values_for row
      row_vals.delete(meta_entity.key) unless meta_entity.is_core
      rec = meta_entity.model_get.first(row_vals)
      rec.destroy
    end

    def insert_row(row)
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
