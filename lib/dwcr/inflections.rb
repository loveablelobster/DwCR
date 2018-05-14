# frozen_string_literal: true

Sequel.inflections do |inflect|
  inflect.uncountable 'multimedia'
  inflect.uncountable(/media$/)
end

String.inflections do |inflect|
  inflect.uncountable 'multimedia'
  inflect.uncountable(/media$/)
end
