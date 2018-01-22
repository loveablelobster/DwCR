# frozen_string_literal: true

require_relative '../helpers/dynamic_model_queryable'
#
module DwCR
  # Creates a Sequel::Model class for a MetaEntity instance
  # adds all associations given for the MetaEntity instance
  def self.create_model(entity, associations)
    model_class = Class.new(Sequel::Model(entity.table_name)) do
      extend DynamicModelClassQueryable
      include DynamicModelQueryable
      @meta_entity = entity
      associations.each do |association|
        associate(*association)
        next if association[0] == :many_to_one
        plugin :association_dependencies
        add_association_dependencies(association[1] => :destroy)
      end
    end
    const_set entity.class_name, model_class
    model_class
  end

  # Loads models for all MetaEntity instances in the MetaArchive instance
  # if no explicit MetaArchive instance is given, it will load the first
  def self.load_models(archive = MetaArchive.first)
    archive.meta_entities.map do |entity|
      entity_model = DwCR.create_model(entity, entity.model_associations)
      MetaEntity.associate(:one_to_many,
                           entity.table_name,
                           class: entity_model)
      entity_model
    end
  end
end
