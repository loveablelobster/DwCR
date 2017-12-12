# frozen_string_literal: true

Sequel.inflections do |inflect|
  inflect.uncountable 'multimedia'
end

String.inflections do |inflect|
  inflect.uncountable 'multimedia'
end
