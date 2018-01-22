# frozen_string_literal: true

# set custom CSV::Converters
CSV::Converters[:safe_numeric] = lambda do |field|
  case field.strip
  when /^-?[0-9]+$/
    field.to_i
  when /^-?[0-9]*\.[0-9]+$/
    field.to_f
  else
    field
  end
end

CSV::Converters[:blank_to_nil] = lambda do |field|
  field&.empty? ? nil : field
end
