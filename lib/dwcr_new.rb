# frozen_string_literal: true

schema_opts = {}

SHELL.options.each do |opt, arg|
  case opt
  when '--help'
    SHELL.print_help
    exit true
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

meta ||= SHELL.path

DB = Sequel.sqlite(SHELL.target)

DwCR.create_metaschema

archive = DwCR::MetaArchive.create(path: SHELL.path)

archive.parse_meta(meta)

DwCR::MODELS = DwCR.create_schema(archive, schema_opts)

DwCR.load_contents_for archive

binding.pry

puts 'done!'
