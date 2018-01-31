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
    xml = arg
  when '--path'
    SHELL.path = arg
  when '--target'
    SHELL.target = arg.empty? ? nil : arg
  end
end

xml ||= SHELL.path

DB = Sequel.sqlite(SHELL.target)

DwCR.create_metaschema

archive = DwCR::MetaArchive.create(path: SHELL.path)

meta_doc = XMLParsable.load_meta xml

archive.load_nodes_from meta_doc

DwCR.create_schema(archive, schema_opts)

DwCR::MODELS = DwCR.load_models(archive)

DwCR.load_contents_for archive

binding.pry

puts 'done!'
