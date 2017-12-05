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
      @schemafile = TableContents.new(@path, @schema)
    end

    it 'gets the file as table with headers' do
      expect(@schemafile.table).to eq(CSV.table(@path + 'expected_table.csv', converters: nil))
    end

    it 'determines the maximum length for each column' do
      expect(@schemafile.max_length(:coreid)).to eq(36)
      expect(@schemafile.max_length(:identifier)).to eq(36)
      expect(@schemafile.max_length(:access_uri)).to eq(30)
      expect(@schemafile.max_length(:title)).to eq(22)
      expect(@schemafile.max_length(:format)).to eq(10)
      expect(@schemafile.max_length(:owner)).to eq(0)
      expect(@schemafile.max_length(:rights)).to eq(16)
    end

    after(:all) do
    	File.delete('spec/files/media.dwc')
    end
  end
end
