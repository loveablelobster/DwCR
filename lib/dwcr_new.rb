# frozen_string_literal: true

SHELL.options.each do |opt, arg|
  case opt
  when '--help'
    SHELL.print_help
  when '--path'
    SHELL.path = arg
  when '--target'
    SHELL.target = arg.empty? ? nil : arg
  end
end

DB = Sequel.sqlite(SHELL.target)

binding.pry

puts 'done!'
