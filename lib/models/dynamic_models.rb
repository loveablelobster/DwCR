# frozen_string_literal: true

require_relative '../helpers/dynamic_model_queryable'
#
module DwCR
  # Creates a Sequel::Model class for a MetaEntity instance
  # adds all associations given for the MetaEntity instance
  def self.create_model(entity)
    model_class = Class.new(Sequel::Model(entity.table_name)) do
      include DynamicModelQueryable
      @meta_entity = entity
      entity.model_associations.each do |association|
        associate(*association)
        next if association[0] == :many_to_one
        plugin :association_dependencies
        add_association_dependencies(association[1] => :destroy)
      end

      define_singleton_method(:finalize) do
        @meta_entity = nil
        Module.nesting.last.send(:remove_const, entity.class_name)
      end
    end
    const_set entity.class_name, model_class
    model_class
  end
end
