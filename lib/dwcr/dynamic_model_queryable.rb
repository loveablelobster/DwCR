# frozen_string_literal: true

# convenience methods for the dynamic models
module DynamicModelQueryable
  # convenience class methods for the dynamic models
  module DynamicModelClassQueryable
    # Returns the _term_ or _baseterm_ for a column name.
    # <em>col_name</em> the column name, can be passed as Symbol or String.
    def attribute_for(col_name)
      entity.attributes_dataset.first(name: col_name.to_s)
    end

    # Returns the Metschema::Entity the class belongs to.
    def entity
      @entity
    end

    # Returns a nested array of all keys/terms/baseterms in the order values
    # will be inserted by the #to_a method of the DynamicModelQueryable mixin.
    def template(keys = :term)
      tmpl = columns.map { |c| attribute_for(c)&.send(keys) }.compact
      return tmpl unless entity.is_core
      entity.extensions.each do |xtn|
        tmpl << xtn.model_get.template(keys)
      end
      tmpl
    end
  end

  def self.included(host_class)
    host_class.extend(DynamicModelClassQueryable)
  end

  # Returns the related core row of an extension row
  # will return nil if the row is a core row itself
  def core_row
    return nil if entity.is_core
    send(entity.core.name)
  end

  # Returns an array of all related extension rows of a core row
  # will return nil if the row is an extension itself
  def extension_rows
    return nil unless entity.is_core
    entity.extensions.map { |xtn| send(xtn.table_name) }.flatten
  end

  # Returns a value hash for the row without primary or foreign keys
  def row_values
    keys_to_delete = %i[id entity_id]
    keys_to_delete.push(entity.core&.foreign_key).compact
    to_hash.clone.delete_if { |key, _| keys_to_delete.include? key }
  end

  # Returns a nested array of values only in consistent order
  def to_a
    row_array = row_values.map { |_key, value| value }
    return row_array unless entity.is_core
    entity.extensions.inject(row_array) do |memo, xtn|
      memo << send(xtn.table_name).map(&:to_a)
    end
  end

  # Returns a value hash for the row without primary or foreign keys
  # where the keys in the hash can be the _term_, _baseterm_, or _name_
  # of the attributes, depending on the argument given
  def to_hash_with(keys = :term)
    return row_values if keys == :name
    row_values.transform_keys do |key|
      attribute = entity.attributes_dataset.first(name: key.to_s)
      attribute.send(keys)
    end
  end

  # Returns the full record as JSON
  def to_json
    JSON.generate(to_record)
  end

  # Returns a full record (current row and all related rows)
  # as a hash with kes as specified in the argument
  # either as _term_, _baseterm_, or _name_
  def to_record(keys: :term)
    record_hash = to_hash_with(keys)
    if entity.is_core
      extension_rows.each do |row|
        key = row.entity.send(keys)
        record_hash[key] ||= []
        record_hash[key] << row.to_hash_with(keys)
      end
    else
      record_hash[entity.core.send(keys)] = core_row.to_hash_with(keys)
    end
    record_hash
  end
end
