# frozen_string_literal: true

SHELL.options.each do |opt, arg|
  case opt
  when '--help'
    SHELL.print_help
  end
end

SHELL.target = ARGV.shift

DB = Sequel.sqlite(SHELL.target)

# FIXME: these requires should not be in DwCR::create_metaschema
require_relative '../models/meta_archive'
require_relative '../models/meta_entity'
require_relative '../models/meta_attribute'
require_relative '../models/content_file'

DwCR::MODELS = DwCR.load_models

puts "this should be loading #{SHELL.target}"

binding.pry

puts 'done!'
