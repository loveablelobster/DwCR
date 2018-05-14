# frozen_string_literal: true

Sequel.inflections do |inflect|
#   inflect.uncountable 'multimedia'
#   inflect.uncountable 'media'
  inflect.singular(/(media)$/i, '\1')
  inflect.plural(/(media)$/i, '\1')
  inflect.irregular 'taxon', 'taxa'
  inflect.uncountable 'metadata'
end

String.inflections do |inflect|
#   inflect.uncountable 'multimedia'
#   inflect.uncountable 'media'
  inflect.singular(/(media)$/i, '\1')
  inflect.plural(/(media)$/i, '\1')
  inflect.irregular 'taxon', 'taxa'
  inflect.uncountable 'metadata'
end
