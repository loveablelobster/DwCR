# frozen_string_literal: true

require 'csv'
require 'set'

# set custom CSV::Converters
CSV::Converters[:safe_numeric] = lambda do |field|
  case field.strip
  when /^-?[0-9]+$/
    field.to_i
  when /^-?[0-9]*\.[0-9]+$/
    field.to_f
  else
    field
  end
end

CSV::Converters[:blank_to_nil] = lambda do |field|
  field&.empty? ? nil : field
end

#
module DwCR
  def self.analyze(files)
    columns = {}
    files.each do |file|
      # read the CSV::Table
      table = CSV.read(file,
                       headers: headers(file),
                       converters: [:blank_to_nil, :safe_numeric, :date] )

      # build columns hash
      table.by_col!.each do |col|
        columns[col[0]] ||= []
        cells = col[1].compact
        t = collapse(cells.map(&:class).uniq)
        l = cells.map(&:to_s).map(&:length).max || 0
        columns[col[0]] << { length: l, type: t }
      end

      # consolidate array of hashes of column info (one hash per file) into single hash
      columns.each { |k, v| columns[k] = consolidate v }
    end
    columns
  end

#   private

  def self.collapse(types)
    return types.first if types.size == 1
    return nil if types.empty? # or String
    return String if types.include?(String)
    return Float if types.size == 2 && types.include?(Float) && types.include?(Integer)
    String
  end

  # reads the first line of the CSV file
  # returns the columns indices as an array
  def self.headers(file)
    CSV.open(file, &:readline).size.times.collect { |i| i }
  end

  def self.consolidate(array_of_hashes)
    return array_of_hashes.first if array_of_hashes.size == 1
    lengths = array_of_hashes.map { |h| h[:length] }
    types = array_of_hashes.map { |h| h[:type] }.uniq

    col_type = if types.size == 1
      types.first
    elsif types.size == 2 && types.include?(Float) && types.include?(Integer)
      Float
    else
      String
    end
    { length: lengths.max, type: col_type }
  end
end
