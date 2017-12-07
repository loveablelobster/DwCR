# frozen_string_literal: true

require 'psych'

require_relative '../lib/dwc_gemstone'

#
module DwCGemstone
  RSpec.describe DwCGemstone do
  	before(:all) do
      @gemstone = DwCGemstone.new('spec/files/meta.xml')
    end

    it 'holds the schema' do
    	expect(@gemstone.schema.core.name).to eq(:occurrence)
    	expect(@gemstone.schema.extensions).to be_an Array
      expect(@gemstone.schema.extensions.length).to be 1
      expect(@gemstone.schema.extensions.first.name).to be :multimedia
    end

    it 'reads the contents and creates .dwc files' do
    	expect(@gemstone.contents[:multimedia].file).to eq(Pathname.new('spec/files/multimedia.dwc'))
    	expect(@gemstone.contents[:occurrence].file).to eq(Pathname.new('spec/files/occurrence.dwc'))
    end

    after(:all) do
      @gemstone.contents.each_value { |c| File.delete(c.file) }
    end
  end
end
