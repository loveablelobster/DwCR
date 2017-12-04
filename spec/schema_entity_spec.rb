# frozen_string_literal: true

require 'psych'

require_relative '../lib/archive_store'
require_relative '../lib/schema_entity'

#
module DwCGemstone
  RSpec.describe SchemaEntity do
    before(:all) do
#       ArchiveStore.instance.connect('dwca_spec.db')
      @doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      @core = SchemaEntity.new(@doc.css('core').first)
      @media = SchemaEntity.new(@doc.css('extension').first)
    end

    context 'determines the kind' do
      it 'determines the kind' do
        expect(@core.kind).to eq(:core)
      end

      it 'raises and exception if the kind is invalid' do
        expect { SchemaEntity.new(@doc.css('invalid').first) }.to raise_error(RuntimeError, 'invalid node: invalid')
      end
    end

    it 'gets the term' do
      expect(@core.term).to eq('http://rs.tdwg.org/dwc/terms/Occurrence')
    end

    context 'gets the columns' do
      it 'gets the columns' do
        expect(@core.attributes).to eq(Psych.load_file('spec/files/expected_columns.yml')['occurrence'])
      end

      it 'ensures unique column names' do
        expect(@media.attributes).to include(term: 'http://purl.org/dc/elements/1.1/rights',
                                             name: :rights!,
                                             default: 'http://creativecommons.org/licenses/by/4.0/deed.en_US')
      end

      it 'sets the default for existing columns' do
        expect(@media.attributes).to include(term: 'http://purl.org/dc/terms/rights',
                                             name: :rights,
                                             index: 6,
                                             default: '© 2008 XY Museum')
      end

      it 'gets the id colum' do
        expect(@core.key).to eq(primary: 0)
      end

      it 'inserts the id column for extensions' do
      	expect(@media.key).to eq(foreign: 0)
      end
    end

    it 'determined the maximum length for each column' do pending 'questionable feature'
      #
    end
  end
end
