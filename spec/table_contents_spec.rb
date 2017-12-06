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
      @contents = TableContents.new(@path, @schema)
    end

    it 'has a shortname (symbol)' do
      expect(@contents.name).to eq(:multimedia)
    end

    it 'loads all files into a CSV::Table' do
      expect(@contents.table).to eq(CSV.table(@path + 'expected_table.csv', converters: nil))
    end

    it 'holds a reference to the generated .dwc file' do
    	expect(@contents.file).to eq(Pathname.new('spec/files/multimedia.dwc'))
    end

    it 'determines the maximum length for each column' do
      expect(@contents.max_length(:coreid)).to eq(36)
      expect(@contents.max_length(:identifier)).to eq(36)
      expect(@contents.max_length(:access_uri)).to eq(30)
      expect(@contents.max_length(:title)).to eq(22)
      expect(@contents.max_length(:format)).to eq(10)
      expect(@contents.max_length(:owner)).to eq(0)
      expect(@contents.max_length(:rights)).to eq(16)
    end

    after(:all) do
    	File.delete(@contents.file)
    end
  end
end
