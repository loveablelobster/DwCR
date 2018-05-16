# frozen_string_literal: true

INFLECTIONS = [
  [:singular, /(media)$/i, '\1'],
  [:plural, /(media)$/i, '\1'],
  [:irregular, 'taxon', 'taxa'],
  [:uncountable, 'metadata']
].freeze

Sequel.inflections do |inflect|
  INFLECTIONS.each { |i| inflect.send(*i) }
end

String.inflections do |inflect|
  INFLECTIONS.each { |i| inflect.send(*i) }
end
