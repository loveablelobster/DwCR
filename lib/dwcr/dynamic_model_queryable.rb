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

  def column_by_term(term)
    entity.attributes_dataset.first(term: term.to_s)&.column_name
  end

  def source_files
    entity.files
  end

  def core?
    entity.is_core
  end

  def record_term
    entity.term
  end

  def attribute_for(column_name)
    entity.attributes_dataset.first(name: column_name.to_s)
  end

  def extension_rows
    entity.extensions.map { |extension| [extension, self.send(extension.table_name)] }
  end

  def record_values
    keys_to_delete = %i{id entity_id}
    keys_to_delete << entity.core&.foreign_key# unless core?
    to_hash.clone.delete_if { |key, _| keys_to_delete.compact.include? key }
  end

  def to_hash_with_keys(keys = :term)
    record_values.transform_keys { |key| attribute_for(key).send(keys) }
  end

  def to_json(keys: :term)
    keys_to_delete = %i{id entity_id}
    keys_to_delete << entity.foreign_key if core?

    hash = to_hash_with_keys(keys)

    extension_rows.each do |rowset|
      key = rowset[0].send(keys)
      hash[key] = rowset[1].map { |row| row.to_hash_with_keys(keys) }
    end

    hash
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
