# frozen_string_literal: true

require 'getoptlong'
require 'psych'

#
module DwCR
  #
  class Shell
    attr_accessor :path
    attr_reader :options, :target

    def initialize(cmd)
      cmd_shell = Psych.load_file(File.join(__dir__, 'help.yml'))[cmd]
      @usage = ["Usage: #{cmd_shell['usage']}\n"]
      @options = nil
      @usage << load_options(cmd_shell['options'])
      @path = Dir.pwd
      @target = target_directory @path
    end

    def print_help
      puts @usage
    end

    def target=(target_path)
      @target = target_path ? target_directory(target_path) || target_path : nil
    end

    private

    def load_options(raw_opts)
      cmd_opts = []
      pp_opts = raw_opts.map do |opt|
        cmd_opts << opt[0..1].append(GetoptLong.const_get(opt[2]))
        str = "    #{opt[1]}    #{opt[0]}"
        fill = ''
        (40 - str.length).times { fill += ' ' }
        blankfill = ''
        40.times { blankfill += ' ' }
        optlines = opt[3].lines
        firstline = str + fill + optlines.shift
        [firstline, optlines.map { |line| blankfill + line }].join#("\n")
      end
      @options = GetoptLong.new(*cmd_opts)
      pp_opts
    end

    def target_directory(target_path)
      return nil unless File.directory? target_path
      File.join(target_path, File.basename(@path) + '.db')
    end
  end
end
