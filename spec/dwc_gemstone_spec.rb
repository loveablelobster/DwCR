# frozen_string_literal: true

require 'psych'

require_relative '../lib/dwc_gemstone'

#
module DwCGemstone
  RSpec.describe DwCGemstone do
  	before(:all) do
      @gemstone = DwCGemstone.new('spec/files/meta.xml')
    end

    context 'on initialzation it' do
      it 'parses the schema' do
        expect(@gemstone.schema.core.name).to eq(:occurrence)
        expect(@gemstone.schema.extensions).to be_an Array
        expect(@gemstone.schema.extensions.length).to be 1
        expect(@gemstone.schema.extensions.first.name).to be :multimedia
      end

      it 'reads the contents and creates .dwc files' do
        expect(@gemstone.contents[:multimedia].file).to eq(Pathname.new('spec/files/multimedia.dwc'))
        expect(@gemstone.contents[:occurrence].file).to eq(Pathname.new('spec/files/occurrence.dwc'))
      end

      it 'updates the lengths of the schema attributes' do
        expect(@gemstone.schema
                        .entities
                        .first
                        .attributes
                        .map(&:length)).to eq([36, 6, 19, 16, 8, 10, 81, 112,
                                               43, 10, 19, 18, 18, 20, 27, 49,
                                               13, 35, 46, 29, 70, 20, 19, 11,
                                               98, 217, 15, 14, 0, 5, 10, 10, 4,
                                                25, 53, 20, 2, 17, 59, 8, 8, 4])
        expect(@gemstone.schema
                        .entities
                        .last
                        .attributes
                        .map(&:length)).to eq([36, 36, 30, 22, 10,
                                               0, 16, 0, 0, 53])
      end
    end

    after(:all) do
      @gemstone.contents.each_value { |c| File.delete(c.file) }
    end
  end
end
