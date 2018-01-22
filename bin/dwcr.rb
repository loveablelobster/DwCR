# frozen_string_literal: true

require 'getoptlong'

require 'pry'

require_relative '../lib/dwcr'
require_relative '../lib/dwcr_shell'
require_relative '../lib/db/schema'

dwcr_cmds = %w[new]

this_cmd = dwcr_cmds.include?(ARGV[0]) ? ARGV.shift : nil

SHELL = DwCR::Shell.new this_cmd

if this_cmd
  scrpt_dir = __dir__.split('/')
  scrpt_dir.pop
  scrpt_dir.push 'lib'
  cmd_scrpt = File.join(scrpt_dir, "dwcr_#{this_cmd}.rb")
  load cmd_scrpt
end

SHELL.options.each do |opt, arg|
  case opt
  when '--help'
    SHELL.print_help
  end
end
