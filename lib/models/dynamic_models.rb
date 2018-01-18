# frozen_string_literal: true

require_relative '../helpers/dynamic_model_queryable'
#
module DwCR
  #
  #
  #
  def self.create_model(entity, associations)
    model_class = Class.new(Sequel::Model(entity.table_name)) do
      extend DynamicModelQueryable
      include DynamicModel
      @meta_entity = entity
      associations.each do |association|
        associate(*association)
        next if association[0] == :many_to_one
        plugin :association_dependencies
        add_association_dependencies(association[1] => :destroy)
      end

      define_singleton_method :meta_entity do
        @meta_entity
      end
    end

    const_set entity.class_name, model_class
    model_class
  end

  # Load models for all MetaEntity instances
  #
  #
  def self.load_models
    MetaEntity.map do |entity|
      entity_model = DwCR.create_model(entity, entity.model_associations)
      MetaEntity.associate(:one_to_many,
                             entity.table_name,
                             class: entity_model)
      entity_model
    end
  end
end

# convenience methods for the dynamic models
module DynamicModel
  def column_by_term(term)
    meta_entity.meta_attributes_dataset.first(term: term.to_s).column_name
  end

  def conten_files
    meta_entity.files
  end

  def core?
    meta_entity.is_core
  end

  def record_term
    meta_entity.term
  end

  def term_for(column_name)
    meta_entity.meta_attributes_dataset.first(name: column_name.to_s).term
  end

  def method_missing(name, *args, &block)
    # FIXME: should treat assignment method '='
    term = column_by_term(name)
    super unless term
    send(term, *args, &block)
  end

  def respond_to_missing?(name, include_private = false)
    column_by_term(name) ? true : super
  end
end
