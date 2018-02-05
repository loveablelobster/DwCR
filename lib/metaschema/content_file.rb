# frozen_string_literal: true

require 'csv'

#
module DwCR
  #
  module Metaschema
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
    # * *#entity*:
    #   the Entity instance the ContentFile instance belongs to
    class ContentFile < Sequel::Model
      many_to_one :entity

      # Returns the full file name including the path
      def file_name
        File.join(path, name)
      end

      # Returns an array of symbols for column names for each column in the
      # (headerless) CSV file specified in the +file+ attribute
      # the array is mapped from the ContentFile instance's parent Entity
      # instance's Attribute instances that have an +index+
      # The array is sorted by the +index+
      def content_headers
        entity.attributes_dataset
              .exclude(index: nil)
              .exclude(type: nil)
              .order(:index)
              .map(&:column_name)
      end

      # Inserts all rows of the CSV file belonging to the ContentFile instance
      # into the table of the DwCA represented by the instance's parent
      # Entity instance
      # Will raise an error for _extension_ instances
      # if the _core_ instance is not loaded
      def load
        return if is_loaded
        load_error = 'core needs to be loaded before extension files'
        raise load_error unless entity.is_core || entity.core.loaded?
        CSV.foreach(file_name) { |row| insert_row(row) }
        self.is_loaded = true
        save
        is_loaded
      end

      # Deletes all rows of the CSV file belonging to the ContentFile instance
      # from the table of the DwCA represented by the instance's parent
      # Entity instance
      # *Warning*: If this is called on a _core_ instance,
      # this will also destroy any dependant _extension_ records!
      def unload!
        return unless is_loaded
        CSV.foreach(file_name) { |row| delete_row(row) }
        self.is_loaded = false
        save
      end

      private

      # removes all cells from a row for which the column in all
      # associated CSV files is empty (the associated Attribute instance
      # has <tt>type == nil</tt>)
      def compact(row)
        empty_cols = entity.attributes_dataset
                           .exclude(index: nil)
                           .where(type: nil)
                           .map(&:index)
        row.delete_if.with_index { |_, index| empty_cols.include?(index) }
      end

      # Delets a CSV row from the DwCA table represented
      # by the instance's parent Entity instance
      def delete_row(row)
        row_vals = row_to_hash row
        row_vals.delete(entity.key) unless entity.is_core
        rec = entity.model_get.first(row_vals)
        rec.destroy
      end

      # Inserts a CSV row into the DwCA schema's _core_ table
      def insert_into_core(row)
        return unless entity.is_core
        entity.model_get.create(row_to_hash(row))
      end

      # Inserts a CSV row into an _extension_ table of the DwCA schema
      def insert_into_extension(row)
        row_vals = row_to_hash row
        core_row(row_vals.delete(entity.key)).send(add_related, row_vals)
      end

      # Inserts a CSV row into the DwCA table represented
      # by the instance's parent Entity instance
      def insert_row(row)
        rec = insert_into_core(row) || insert_into_extension(row)
        entity.send(add_related, rec)
      end

      # Returns the row from the DwCA _core_ that matches the foreign key
      def core_row(foreign_key)
        entity.core.model_get.first(entity.core.key => foreign_key)
      end

      # Returns a string that is the method name to add a related record via
      # an association on the DwCA model
      def add_related
        'add_' + entity.name.singularize
      end

      # Creates a hash from a headerless CSV row
      # Entity instance's :attributes colum names are keys
      # the CSV row cells are values
      def row_to_hash(row)
        keys = content_headers
        vals = compact row
        keys.zip(vals).to_h.select { |_k, v| v && !v.empty? }
      end
    end
  end
end
