# frozen_string_literal: true

require 'getoptlong'

require 'pry'

require_relative '../lib/dwcr'
require_relative '../lib/cli/dwcr_shell'

dwcr_cmds = %w[load new]

this_cmd = dwcr_cmds.include?(ARGV[0]) ? ARGV.shift : nil

SHELL = DwCR::Shell.new this_cmd

if this_cmd
  scrpt_dir = __dir__.split('/')
  scrpt_dir.pop
  scrpt_dir.concat %W[lib cli dwcr_#{this_cmd}.rb]
  cmd_scrpt = File.join scrpt_dir
  load cmd_scrpt
end

SHELL.options.each do |opt, arg|
  case opt
  when '--help'
    SHELL.print_help
  end
end
