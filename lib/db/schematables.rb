# frozen_string_literal: true

require 'psych'
require 'sqlite3'

#
module DwCR
  def self.create_metaschema
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

  def self.create_schema_table(entity)
    DB.create_table? entity.table_name do
      primary_key :id
      foreign_key :meta_entity_id, :meta_entities
      DwCR.add_foreign_key(self, entity)
      entity.meta_attributes.each do |a|
        column(*a.to_table_column) unless a.foreign_key?
      end
    end
  end

  def self.add_foreign_key(table, entity)
    return unless entity.core
    table.foreign_key(entity.core.foreign_key, entity.core.table_name)
  end

  def self.inspect_table(table, method)
    DB.indexes(table).values.map { |x| x[:columns] }.flatten
    DB.send(method, table)
  rescue Sequel::Error
    false
  end

  def self.columns?(table, columns)
    db_cols = inspect_table(table, :schema)
    return unless db_cols
    exp_cols = columns.map(&:first).unshift(:id)
    exp_cols == db_cols.map(&:first)
  end

  def self.indexes?(table, columns)
    db_idxs = inspect_table(table, :indexes)
    return unless db_idxs
    exp_idxs = columns.select { |column| column[2]&.fetch(:index, false) }
                      .map(&:first)
    exp_idxs == db_idxs.values.map { |x| x[:columns] }.flatten
  end

  def self.metaschema?
    tabledefs = Psych.load_file('lib/store/metaschema.yml')
    status = tabledefs.map { |td| columns?(*td) && indexes?(*td) }.uniq
    return false if status.size > 1
    status.first
  end
end
