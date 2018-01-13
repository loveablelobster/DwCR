# frozen_string_literal: true

require 'psych'

#
module DwCR
  def self.create_metaschema
    connect unless Sequel::Model.db
    Psych.load_file('lib/store/metaschema.yml').each do |td|
      Sequel::Model.db.create_table? td.first do
        primary_key :id
        td.last.each { |c| column(*c) }
      end
    end
    require_relative '../models/meta_entity'
    require_relative '../models/meta_attribute'
    require_relative '../models/content_file'
  end

  def self.create_schema_table(entity)
    Sequel::Model.db.create_table? entity.table_name do
      primary_key :id
      foreign_key :meta_entity_id, :meta_entities
      DwCR.add_foreign_key(self, entity)
      entity.meta_attributes.each do |a|
        column(*a.column_params) unless a.foreign_key?
      end
    end
  end

  def self.add_foreign_key(table, entity)
    return unless entity.core
    table.foreign_key(entity.core.foreign_key, entity.core.table_name)
  end
end
