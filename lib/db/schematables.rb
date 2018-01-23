# frozen_string_literal: true

require 'psych'

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
end
