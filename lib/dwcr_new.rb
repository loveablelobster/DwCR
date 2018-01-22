# frozen_string_literal: true

meta = nil
schema_opts = {}

SHELL.options.each do |opt, arg|
  case opt
  when '--help'
    SHELL.print_help
  when '--coltypes'
    schema_opts[:type] = true
  when '--meta'
    meta = arg
  when '--path'
    SHELL.path = arg
  when '--target'
    SHELL.target = arg.empty? ? nil : arg
  end
end

DB = Sequel.sqlite(SHELL.target)

DwCR.create_metaschema

schema = DwCR::Schema.new(path: SHELL.path)

schema.load_meta(meta)

schema.create_schema(schema_opts)

schema.load_contents

binding.pry

puts 'done!'
