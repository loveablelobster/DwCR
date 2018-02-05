# frozen_string_literal: true

module CLI
  SHELL.options.each do |opt, arg|
    case opt
    when '--help'
      SHELL.print_help
      exit true
    end
  end

  SHELL.target = ARGV.shift

  ::DB = Sequel.sqlite(SHELL.target)

  # FIXME: these requires should not be in DwCR::create_metaschema
  require_relative '../dwcr/metaschema/archive'
  require_relative '../dwcr/metaschema/entity'
  require_relative '../dwcr/metaschema/attribute'
  require_relative '../dwcr/metaschema/content_file'

  DwCR::MODELS = DwCR.load_models

  puts "this should be loading #{SHELL.target}"

  binding.pry

  puts 'done!'
end
