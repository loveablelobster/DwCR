# frozen_string_literal: true

require_relative '../lib/archive_store'
require_relative '../lib/meta_parser'
#
module DwCR
  RSpec.configure do |config|
    config.warnings = false
  end

  RSpec.describe 'SchemaAttribute' do
    before(:all) do
      @db = ArchiveStore.instance.connect
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      DwCR.parse_meta(doc).last[:schema_attributes].map { |s| SchemaAttribute.create(s) }
    end

    context 'it persists SchemaAttribute objects' do
      it 'persists all nodes as SchemaAttribute objects' do
        expect(SchemaAttribute.all.count).to be 10
      end

      context 'upon initialization it presists' do
        it 'the ontological term as string' do
          expect(SchemaAttribute.all.map(&:term)).to contain_exactly(nil,
                                                                     'http://purl.org/dc/terms/identifier',
                                                                     'http://rs.tdwg.org/ac/terms/accessURI',
                                                                     'http://purl.org/dc/terms/title',
                                                                     'http://purl.org/dc/terms/format',
                                                                     'http://ns.adobe.com/xap/1.0/rights/Owner',
                                                                     'http://purl.org/dc/terms/rights',
                                                                     'http://rs.tdwg.org/ac/terms/licenseLogoURL',
                                                                     'http://ns.adobe.com/photoshop/1.0/Credit',
                                                                     'http://purl.org/dc/elements/1.1/rights')
          # to be nil where there is no term
          # find coreid
          # rewrite above exampe to find set
        end

        it 'the short name' do
          expect(SchemaAttribute.all.map(&:name)).to contain_exactly('coreid',
                                                                     'identifier',
                                                                     'access_uri',
                                                                     'title',
                                                                     'format',
                                                                     'owner',
                                                                     'rights',
                                                                     'license_logo_url',
                                                                     'credit',
                                                                     'rights')
        end

        it 'the alt_name' do
          expect(SchemaAttribute.all.map(&:alt_name)).to contain_exactly('coreid',
                                                                      'identifier',
                                                                      'access_uri',
                                                                      'title',
                                                                      'format',
                                                                      'owner',
                                                                      'rights',
                                                                      'license_logo_url',
                                                                      'credit',
                                                                      'rights!')
        end

        context 'the index of the column in the DwCA source file' do
          it 'an integer for the index if there is one' do
            expect(SchemaAttribute[1].index).to be 0
            expect(SchemaAttribute[2].index).to be 1
            expect(SchemaAttribute[3].index).to be 2
            expect(SchemaAttribute[4].index).to be 3
            expect(SchemaAttribute[5].index).to be 4
            expect(SchemaAttribute[6].index).to be 5
            expect(SchemaAttribute[7].index).to be 6
            expect(SchemaAttribute[8].index).to be 7
            expect(SchemaAttribute[9].index).to be 8
		      end

          it 'nil if there is no index' do
            expect(SchemaAttribute[10].index).to be_nil
          end
        end

        context 'the default value' do
          it 'the default value for the column' do
            expect(SchemaAttribute[7].default).to eq '© 2008 XY Museum'
            expect(SchemaAttribute[10].default).to eq 'http://creativecommons.org/licenses/by/4.0/deed.en_US'
          end

          it 'nil if there is no default value' do
            expect(SchemaAttribute.all.map(&:default)[0..5]).to contain_exactly(nil, nil, nil, nil, nil, nil)
            expect(SchemaAttribute.all.map(&:default)[7..8]).to contain_exactly(nil, nil)
          end
        end
      end

      context 'returns the length of the column equal to' do
        it 'the length of the default value' do
          expect(SchemaAttribute[7].length).to be 16
          expect(SchemaAttribute[10].length).to be 53
        end

        it 'the maximum content length if given and no default set' do
          attr = SchemaAttribute[1]
          attr.max_content_length = 32
          expect(attr.length).to be 32
        end

        it 'the maximum content length if given and larger than the default' do
          attr = SchemaAttribute[10]
          attr.max_content_length = 100
          expect(attr.length).to be 100
        end

        it 'the default length if longer than a given max content length' do
          attr = SchemaAttribute[10]
          attr.max_content_length = 20
          expect(attr.length).to be 53
        end

        it 'nil if there is no default value' do
          expect(SchemaAttribute.all.map(&:length)[0..5]).to contain_exactly(nil, nil, nil, nil, nil, nil)
          expect(SchemaAttribute.all.map(&:length)[7..8]).to contain_exactly(nil, nil)
        end
      end

      context 'returns indexing options' do
        it 'returns false if the column should not be indexed' do
          expect(SchemaAttribute[2].index_options).to be_falsey
        end

        it 'returns true if the column should be indexed' do
          expect(SchemaAttribute[1].index_options).to be_truthy
        end

        it 'returns a unique index as a hash option' do
          attr = SchemaAttribute[1]
          attr.has_index = true
          attr.is_unique = true
          expect(attr.index_options).to include(:unique => true)
        end
      end
    end
  end
end
