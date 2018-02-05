# frozen_string_literal: true

#
module DwCR
  # Creates a Sequel::Model class for a Entity instance
  # adds all associations given for the Entity instance
  def self.create_model(entity)
    model_class = Class.new(Sequel::Model(entity.table_name)) do
      include DynamicModelQueryable
      @entity = entity
      entity.model_associations.each do |association|
        associate(*association)
        next if association[0] == :many_to_one
        plugin :association_dependencies
        add_association_dependencies(association[1] => :destroy)
      end

      define_singleton_method(:finalize) do
        @entity = nil
        Module.nesting.last.send(:remove_const, entity.class_name)
      end
    end
    const_set entity.class_name, model_class
    model_class
  end
end
