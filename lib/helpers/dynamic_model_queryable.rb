# frozen_string_literal: true

#
module DynamicModelClassQueryable
  def meta_entity
    @meta_entity
  end

  def column_by_term(term)
    meta_entity.meta_attributes_dataset.first(term: term.to_s).column_name
  end

  def query_by_term(term, val)
    where(column_by_term(term) => val)
  end

  def query_by_terms(val_hash)
    val_hash.transform_keys { |key| column_by_term(key) }
    where(val_hash)
  end
end

# convenience methods for the dynamic models
module DynamicModelQueryable
  def column_by_term(term)
    meta_entity.meta_attributes_dataset.first(term: term.to_s).column_name
  end

  def source_files
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
