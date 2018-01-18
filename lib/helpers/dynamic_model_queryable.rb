# frozen_string_literal: true

#
module DynamicModelQueryable
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
