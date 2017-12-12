# frozen_string_literal: true

require 'psych'

require_relative '../lib/schema_entity'

#
module DwCR
  RSpec.describe SchemaEntity do
    before(:all) do
      @doc = File.open('spec/files/meta_spec.xml') { |f| Nokogiri::XML(f) }
      @core = SchemaEntity.new(@doc.css('core').first)
      @media = SchemaEntity.new(@doc.css('extension').first)
    end

    context 'determines the kind' do
      it 'determines the kind' do
        expect(@core.kind).to be :core
        expect(@media.kind).to be :extension
      end

      it 'raises and exception if the kind is invalid' do
        expect { SchemaEntity.new(@doc.css('invalid').first) }.to raise_error(RuntimeError, 'invalid node: invalid')
      end
    end

    it 'gets the term' do
      expect(@core.term).to eq('http://rs.tdwg.org/dwc/terms/Occurrence')
      expect(@media.term).to eq('http://rs.tdwg.org/ac/terms/Multimedia')
    end

    it 'derives an extension name as symbol from the term' do
      expect(@core.name).to be :occurrence
      expect(@media.name).to be :multimedia
    end

    context 'gets the columns' do
      it 'gets the columns' do
        expect(@core.attributes.map(&:to_h)).to eq(Psych.load_file('spec/files/expected_columns.yml')['occurrence'])
      end

      it 'ensures unique column names' do
        expect(@media.attributes.map(&:to_h)).to include(term: 'http://purl.org/dc/elements/1.1/rights',
                                                         name: :rights,
                                                         alt_name: :rights!,
                                                         default: 'http://creativecommons.org/licenses/by/4.0/deed.en_US',
                                                         length: 53)
      end

      it 'sets the default for existing columns' do
        expect(@media.attributes.map(&:to_h)).to include(term: 'http://purl.org/dc/terms/rights',
                                                         name: :rights,
                                                         alt_name: :rights,
                                                         index: 6,
                                                         default: '© 2008 XY Museum',
                                                         length: 20)
      end

      it 'gets the id colum' do
        expect(@core.key).to eq(primary: :occurrence_id)
      end

      it 'inserts the id column for extensions' do
      	expect(@media.key).to eq(foreign: :coreid)
      end
    end

    it 'gets the names of the contents files' do
    	expect(@core.contents).to eq(['occurrence.csv'])
    	expect(@media.contents).to eq(['media.csv'])
    end

    it 'returns a list of alt_names as content headers, sorted by index' do
    	expect(@media.content_headers).to eq([:coreid,
                                            :identifier,
                                            :access_uri,
                                            :title,
                                            :format,
                                            :owner,
                                            :rights,
                                            :license_logo_url,
                                            :credit])
    end

    it 'sets the database indexing option for primary and foreign key columns' do
      expect(@core.attribute(:occurrence_id).column_schema).to eq([:occurrence_id, :string, { index: { unique: true }, default: nil }])
      expect(@media.attribute(:coreid).column_schema).to eq([:coreid, :string, { index: true, default: nil }])
    end

    it 'updates the attribute lengths' do
      @media.update(coreid: 20, identifier: 20,
                    access_uri: 20,
                    title: 20,
                    format: 20,
                    owner: 20,
                    rights: 20,
                    license_logo_url: 20,
                    credit: 20)
      expect(@media.attributes.map(&:length)).to eq([20, 20, 20, 20, 20, 20, 20, 20, 20, 53])
    end
  end
end
