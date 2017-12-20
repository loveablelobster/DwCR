# frozen_string_literal: true

#
module DwCR
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
  end
end
