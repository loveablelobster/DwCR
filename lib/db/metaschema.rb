# frozen_string_literal: true

require 'psych'
require 'sqlite3'

#
module DwCR
  # This module provides functionality to create, update, and verify the
  # part of the DwCR schema needed to persist information about the DwCR
  module Metaschema
    # Creates the tables for the metaschema present in every DwCR
    # _meta_archives_, _meta_entities_, _meta_attributes_, _content_files_
    # loads the Sequel::Model classes for these tables
    def self.create
      tabledefs = Psych.load_file(File.join(__dir__, 'metaschema_tables.yml'))
      tabledefs.to_h.each do |table, columns|
        DB.create_table? table do
          primary_key :id
          columns.each { |c| column(*c) }
        end
      end
      require_relative '../models/meta_archive'
      require_relative '../models/meta_entity'
      require_relative '../models/meta_attribute'
      require_relative '../models/content_file'
    end

    # Returns schema or index parameters for a table, depending on the
    # second argument (+:schema+ or +:indexes+)
    # returns +false+ if the table does not exist
    def self.inspect_table(table, method)
      DB.indexes(table).values.map { |x| x[:columns] }.flatten
      DB.send(method, table)
    rescue Sequel::Error
      false
    end

    # Performs an integrety check on +table+, veryfies all columns
    # are present with the parameters given in +columns+;
    # a column parameter is an array with the structure:
    # <tt>[:column_name, :column_type, {column_options} ]</tt>
    def self.columns?(table, *columns)
      db_cols = inspect_table(table, :schema)
      return unless db_cols
      exp_cols = columns.map(&:first).unshift(:id)
      exp_cols == db_cols.map(&:first)
    end

    # Performs an integrety check on +table+, veryfies all indices
    # are present with the parameters given in +columns+;
    # a column parameter is an array with the structure:
    # <tt>[:column_name, :column_type, {column_options} ]</tt>
    def self.indexes?(table, *columns)
      db_idxs = inspect_table(table, :indexes)
      return unless db_idxs
      exp_idxs = columns.select { |column| column[2]&.fetch(:index, false) }
                        .map(&:first)
      exp_idxs & db_idxs.values.map { |x| x[:columns] }.flatten == exp_idxs
    end

    # Updates all MetaAttribute instances in a MetaArchive
    # with parameters from files in ContentFile
    # _schema_options_: a Hash with attribute names as keys and boolean values
    # <tt>{ :type => true, :length => true }</tt>
    # updates any attribute given as key where value is _true_
    def self.update(archive, **options)
      return if options.empty?

      # FIXME: throw an error if metaschema is not loaded
      # FIXME: handle situation where schema tables have been created
      options.select! { |_k, v| v == true }
      archive.meta_entities
             .each { |entity| entity.update_meta_attributes!(*options.keys) }
    end

    # Performs an integrity check on the metaschema in the DWCR file
    # (the current database connection)
    # returns true if all tables, columns, and indices as given in
    # _config/metaschema_tables.yml_ are present
    def self.valid?
      tabledefs = Psych.load_file('lib/db/metaschema_tables.yml')
      status = tabledefs.map do |td|
        table = td.first
        columns = td.last
        columns?(table, *columns) && indexes?(table, *columns)
      end
      return false if status.uniq.size > 1
      status.first
    end
  end
end
