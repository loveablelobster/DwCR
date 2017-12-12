# frozen_string_literal: true

require_relative '../lib/schema_attribute'
require_relative '../lib/archive_store'

#
module DwCR
  RSpec.describe SchemaAttribute do
    let(:fields) do
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      field_nodes = doc.css('extension').first.css('field')
      field_nodes.map { |field_node| SchemaAttribute.new(field_node, col_lengths: true) }
    end

    let(:coreid) do
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      SchemaAttribute.new(doc.css('extension').first.css('coreid').first)
    end

    context 'upon initialization it holds' do
      it 'the ontological term as string' do
        expect(fields.map(&:term)).to eq(['http://purl.org/dc/terms/identifier',
                                          'http://rs.tdwg.org/ac/terms/accessURI',
                                          'http://purl.org/dc/terms/title',
                                          'http://purl.org/dc/terms/format',
                                          'http://ns.adobe.com/xap/1.0/rights/Owner',
                                          'http://purl.org/dc/terms/rights',
                                          'http://rs.tdwg.org/ac/terms/licenseLogoURL',
                                          'http://ns.adobe.com/photoshop/1.0/Credit',
                                          'http://purl.org/dc/terms/rights',
                                          'http://purl.org/dc/elements/1.1/rights'])
      end

      it 'the name as symbol' do
        expect(fields.map(&:name)).to eq([:identifier, :access_uri, :title,
                                          :format, :owner, :rights,
                                          :license_logo_url, :credit, :rights,
                                          :rights])
        expect(coreid.name).to be :coreid
      end

      it 'the alt_name identical to the name' do
        expect(fields.map(&:alt_name)).to eq(fields.map(&:name))
      end

      context 'the index' do
        it 'the index of the column in the csv file or nil ' do
          expect(fields.map(&:index)[0..7]).to eq([1, 2, 3, 4, 5, 6, 7, 8])
		    end

        it 'nil if there is no index' do
          expect(fields[8].index).to be_nil
          expect(fields[9].index).to be_nil
        end
      end

      context 'the default value' do
        it 'the default value for the column' do
          expect(fields[8].default).to eq '© 2008 XY Museum'
          expect(fields[9].default).to eq 'http://creativecommons.org/licenses/by/4.0/deed.en_US'
        end

        it 'nil if there is no default value' do
        	expect(fields.map(&:default)[0..7]).to eq([nil, nil, nil, nil, nil, nil,
		                                                 nil, nil])
        end
      end

      context 'the length of the column' do
        it 'equal to the length of the default value' do
          expect(fields[8].length).to be 16
          expect(fields[9].length).to be 53
        end

        it 'nil if there is no default value' do
          expect(fields.map(&:length)[0..7]).to eq([nil, nil, nil, nil, nil, nil,
		                                                nil, nil])
        end
      end

      it 'updates the length if the default is updated' do
        fields[8].default = 'a minimally longer default'
      	expect(fields[8].length).to be 26
      end
    end
  end
end
