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
        expect(SchemaAttribute.all.count).to be >= 10
      end

      context 'upon initialization it presists' do
        it 'the ontological term as string' do
          expect(SchemaAttribute.all.map(&:term)).to include(nil,
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
          expect(SchemaAttribute.all.map(&:name)).to include('coreid',
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
          expect(SchemaAttribute.all.map(&:alt_name)).to include('coreid',
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
            expect(SchemaAttribute.first(alt_name: 'coreid').index).to be 0
            expect(SchemaAttribute.first(alt_name: 'identifier').index).to be 1
            expect(SchemaAttribute.first(alt_name: 'access_uri').index).to be 2
            expect(SchemaAttribute.first(alt_name: 'title').index).to be 3
            expect(SchemaAttribute.first(alt_name: 'format').index).to be 4
            expect(SchemaAttribute.first(alt_name: 'owner').index).to be 5
            expect(SchemaAttribute.first(alt_name: 'license_logo_url').index).to be 7
            expect(SchemaAttribute.first(alt_name: 'credit').index).to be 8
		      end

          it 'nil if there is no index' do
            expect(SchemaAttribute.first(term: 'http://purl.org/dc/elements/1.1/rights').index).to be_nil
          end
        end

        context 'the default value' do
          it 'the default value for the column' do
            expect(SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights').default).to eq '© 2008 XY Museum'
            expect(SchemaAttribute.first(term: 'http://purl.org/dc/elements/1.1/rights').default).to eq 'http://creativecommons.org/licenses/by/4.0/deed.en_US'
          end

          it 'nil if there is no default value' do
            expect(SchemaAttribute.first(term: 'http://rs.tdwg.org/ac/terms/accessURI').default).to be_nil
          end
        end
      end

      context 'returns the length of the column equal to' do
        it 'the length of the default value' do
          expect(SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights').length).to be 16
          expect(SchemaAttribute.first(term: 'http://purl.org/dc/elements/1.1/rights').length).to be 53
        end

        it 'the maximum content length if given and no default set' do
          attr = SchemaAttribute.first(name: 'coreid')
          attr.max_content_length = 32
          expect(attr.length).to be 32
        end

        it 'the maximum content length if given and larger than the default' do
          attr = SchemaAttribute.first(term: 'http://purl.org/dc/elements/1.1/rights')
          attr.max_content_length = 100
          expect(attr.length).to be 100
        end

        it 'the default length if longer than a given max content length' do
          attr = SchemaAttribute.first(term: 'http://purl.org/dc/elements/1.1/rights')
          attr.max_content_length = 20
          expect(attr.length).to be 53
        end

        it 'nil if there is no default value' do
          expect(SchemaAttribute.first(name: 'coreid').length).to be_nil
        end
      end

      context 'returns indexing options' do
        it 'returns false if the column should not be indexed' do
          expect(SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights').index_options).to be_falsey
        end

        it 'returns true if the column should be indexed' do
          expect(SchemaAttribute.first(name: 'coreid').index_options).to be_truthy
        end

        it 'returns a unique index as a hash option' do
          attr = SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights')
          attr.has_index = true
          attr.is_unique = true
          expect(attr.index_options).to include(:unique => true)
        end
      end
    end
  end
end
