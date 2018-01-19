# frozen_string_literal: true

require 'getoptlong'
require 'psych'

#
module DwCR
  #
  class Shell
    attr_reader :options

    def initialize(cmd)
      cmd_shell = Psych.load_file('resources/help.yml')[cmd]
      @usage = ["Usage: #{cmd_shell['usage']}\n"]
      @options = nil
      @usage << load_options(cmd_shell['options'])
    end

    def print_help
      puts @usage
    end

    private

    def load_options(raw_opts)
      cmd_opts = []
      pp_opts = raw_opts.map do |opt|
        cmd_opts << opt[0..1].append(GetoptLong.const_get(opt[2]))
        str = "\t#{opt[1]}\t#{opt[0]}"
        fill = ''
        (40 - str.length).times { fill += ' ' }
        str + fill + opt[3]
      end
      @options = GetoptLong.new(*cmd_opts)
      pp_opts
    end
  end
end
