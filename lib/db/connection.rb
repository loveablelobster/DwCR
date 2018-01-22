# frozen_string_literal: true

require 'sqlite3'

#
module DwCR
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
