# frozen_string_literal: true

require 'psych'

require_relative '../lib/schema_entity'
require_relative '../lib/table_contents'

#
module DwCGemstone
  RSpec.describe TableContents do
    before(:all) do
      @path = 'spec/files/'
      @doc = File.open(@path + 'meta.xml') { |f| Nokogiri::XML(f) }
      @schema = SchemaEntity.new(@doc.css('extension').first)
      @schemafile = TableContents.new(@path + @schema.contents, @schema.attributes)
    end

    it 'gets the file as table with headers' do
      expect(@schemafile.table).to eq(CSV.table(@path + 'expected_table.csv', converters: nil))
    end

    it 'determines the maximum length for each column' do
      expect(@schemafile.column_width(:coreid)).to eq(36)
      expect(@schemafile.column_width(:identifier)).to eq(36)
      expect(@schemafile.column_width(:access_uri)).to eq(30)
      expect(@schemafile.column_width(:title)).to eq(22)
      expect(@schemafile.column_width(:format)).to eq(10)
      expect(@schemafile.column_width(:owner)).to eq(0)
      expect(@schemafile.column_width(:rights)).to eq(16)
    end
  end
end
