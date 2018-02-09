# frozen_string_literal: true

# convenience methods for the dynamic models
module DynamicModelQueryable
  #
  module DynamicModelClassQueryable
    def entity
      @entity
    end

    def column_by_term(term)
      @entity.attributes_dataset.first(term: term.to_s).column_name
    end

    def query_by_term(term, val)
      where(column_by_term(term) => val)
    end

    def query_by_terms(val_hash)
      val_hash.transform_keys { |key| column_by_term(key) }
      where(val_hash)
    end
  end

  def self.included(host_class)
    host_class.extend(DynamicModelClassQueryable)
  end

  #
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

  # Returns a value hash for the row without primary or foreign keys
  # where the keys in the hash can be the _term_, _baseterm_ or _name_
  # of the attributes, depending on the argument given
  def to_hash_with(keys = :term)
    return row_values if keys == :name
    row_values.transform_keys do |key|
      attribute = entity.attributes_dataset.first(name: key.to_s)
      attribute.send(keys)
    end
  end

  def to_record(keys: :term)
    record_hash = to_hash_with(keys)
    extension_rows.each do |row|
      key = row.entity.send(keys)
      record_hash[key] ||= []
      record_hash[key] << row.to_hash_with(keys)
    end
    record_hash
  end
#   def column_by_term(term)
#     entity.attributes_dataset.first(term: term.to_s)&.column_name
#   end
#
#   def source_files
#     entity.files
#   end
#
#   def core?
#     entity.is_core
#   end
#
#   def record_term
#     entity.term
#   end
#
#   def method_missing(name, *args, &block)
#     # FIXME: should treat assignment method '='
#     term = column_by_term(name)
#     super unless term
#     send(term, *args, &block)
#   end
#
#   def respond_to_missing?(name, include_private = false)
#     column_by_term(name) ? true : super
#   end
end
