# frozen_string_literal: true

# convenience methods for the dynamic models
module DynamicModelQueryable
  # convenience class methods for the dynamic models
  module DynamicModelClassQueryable
    # Returns the Metaschema::Attribute for a +column_name+ (the header of the
    # column, can be passed as Symbol or String).
    def attribute_for(column_name)
      entity.attributes_dataset.first(name: column_name.to_s)
    end

    # Returns the Metschema::Entity the class belongs to.
    def entity
      @entity
    end

    # Returns a nested array of all terms in the order values
    # will be returned by #to_a. Each item in the nested array will be an array
    # with the entity term at index 0 and the attribute term at index 1.
    def template(keys = :term)
      tmpl = columns.map do |column|
        next unless attribute = attribute_for(column)
        [attribute.send(keys), entity.send(keys)]
      end.compact
      return tmpl.compact unless entity.is_core
      entity.extensions.each do |xtn|
        tmpl << xtn.model_get.template(keys)
      end
      tmpl
    end
  end

  # Extends the class that DynamicModelQueryable is mixed in with
  # DynamicModelClassQueryable
  def self.included(host_class)
    host_class.extend(DynamicModelClassQueryable)
  end

  # Returns the core row for +self+. Will return +nil+ if +self+ is the core.
  def core_row
    return nil if entity.is_core
    send(entity.core.name)
  end

  # Returns an array of all related extension rows for +self+. Will return +nil+
  # if +self+ is an extension.
  def extension_rows
    return nil unless entity.is_core
    entity.extensions.map { |xtn| send(xtn.table_name) }.flatten
  end

  # Returns a value hash for +self+ without primary or foreign keys.
  def row_values
    keys_to_delete = %i[id entity_id]
    keys_to_delete.push(entity.core&.foreign_key).compact
    to_hash.clone.delete_if { |key, _| keys_to_delete.include? key }
  end

  # Returns a nested array of values only in consistent order.
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

  # Returns the #full_record for +self+ as JSON.
  def to_json
    JSON.generate(to_record)
  end

  # Returns the full record (current row and all related rows) for +self+
  # as a hash with +keys+ (+:term+, +:baseterm+, or +:name+).
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
