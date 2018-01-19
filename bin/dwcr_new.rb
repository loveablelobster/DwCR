# frozen_string_literal: true

target = Dir.pwd

SHELL.options.each do |opt, arg|
  case opt
  when '--help'
    SHELL.print_help
  when '--path'
    path = arg
  when '--target'
    target = arg
  end
end

binding.pry

puts 'done!'
