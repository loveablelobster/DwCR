# frozen_string_literal: true

require 'psych'

require_relative '../lib/dwcr'

#
module DwCR
  RSpec.describe DwCR do
  	before(:all) do
      @gemstone = DwCR.new('spec/files/meta.xml',
                                  location: 'spec/files/test.db',
                                  col_lengths: true)
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

    context 'persists the contents in a SQLite database' do
      it 'creates the SQLite database' do
        @gemstone.make
        expect(@gemstone.store).not_to be_nil
      end

      it 'creates the tables' do
      	@gemstone.build_schema
      	expect(@gemstone.store[:occurrence]).not_to be_nil
      end

      it 'loads all table contents' do
        @gemstone.load_tables
        expect(@gemstone.store[:occurrence].count).not_to be 0
      end
    end

    after(:all) do
      @gemstone.contents.each_value { |c| File.delete(c.file) }
#       File.delete('spec/files/test.db')
    end
  end
end
