# frozen_string_literal: true

module CLI
  SHELL.options.each do |opt, arg|
    case opt
    when '--help'
      SHELL.print_help
      exit true
    when '--interactive'
      SHELL.session = true
    end
  end

  SHELL.target = ARGV.shift

  ::DB = Sequel.sqlite(SHELL.target)

  DwCR::Metaschema.load_models

  DwCR::MODELS = DwCR.load_models

  binding.pry if SHELL.session

  exit true
end
