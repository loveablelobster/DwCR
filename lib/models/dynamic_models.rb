# frozen_string_literal: true

#
module DwCR
  #
  #
  #
  def self.association(left_entity, right_entity)
    options = { class: right_entity.class_name, class_namespace: 'DwCR' }
    if left_entity.is_core
      options[:key] = left_entity.class_name.foreign_key.to_sym
      [:one_to_many, right_entity.table_name, options]
    else
      options[:key] = right_entity.class_name.foreign_key.to_sym
      [:many_to_one, right_entity.name.singularize.to_sym, options]
    end
  end

  #
  #
  #
  def self.create_model(entity, *associations)
    model_class = Class.new(Sequel::Model(entity.table_name)) do
      extend DynamicModelQueries
      include DynamicModel
      @entity = entity
      associations.each do |association|
        associate(*association)
        next if association[0] == :many_to_one
        plugin :association_dependencies
        add_association_dependencies(association[1] => :destroy)
      end

      define_singleton_method :entity do
        @entity
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
      entity_model = DwCR.create_model(entity, *entity.assocs)
      MetaEntity.associate(:one_to_many,
                             entity.table_name,
                             class: entity_model)
      entity_model
    end
  end
end

#
module DynamicModelQueries
  def query_by_term(term, val)
    col_name = entity.meta_attributes_dataset.first(term: term).name.to_sym
    where(col_name => val)
  end

  def query_by_terms(val_hash)
    val_hash.transform_keys do |key|
      entity.meta_attributes_dataset.first(term: term).name.to_sym
    end
    where(val_hash)
  end
end

# convenience methods for the dynamic models
module DynamicModel
  def core?
    meta_entity.is_core
  end

  def record_term
    meta_entity.term
  end

  def term_for(column_name)
    meta_entity.meta_attributes_dataset.first(name: column_name.to_s).term
  end
end
