# frozen_string_literal: true

#
module DwCR
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
  def self.create_model(model_name, source, *associations)
    model_class = Class.new(Sequel::Model(source)) do
      associations.each do |association|
        associate(*association)
        next if association[0] == :many_to_one
        plugin :association_dependencies
        add_association_dependencies(association[1] => :destroy)
      end
    end
    const_set model_name, model_class
    model_class
  end

  #
  def self.load_models
    SchemaEntity.each do |entity|
      entity_model = DwCR.create_model(entity.class_name,
                                       entity.table_name,
                                       *entity.assocs)
      SchemaEntity.associate(:one_to_many,
                             entity.table_name,
                             class: entity_model)
    end
  end
end
