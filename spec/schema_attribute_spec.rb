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
      DwCR.parse_meta(doc)
          .last[:schema_attributes]
          .map { |s| SchemaAttribute.create(s) }
    end

    context 'it persists SchemaAttribute objects' do
      it 'persists all nodes as SchemaAttribute objects' do
        expect(SchemaAttribute.all.count).to be >= 10
      end

      context 'upon initialization it presists' do
        context 'the ontological term' do
          it 'as string if there is a term' do
            a = SchemaAttribute.first(name: 'format')
            expect(a.term).to eq 'http://purl.org/dc/terms/format'
          end

          it 'nil if there is no term' do
            a = SchemaAttribute.first(name: 'coreid')
            expect(a.term).to be_nil
          end
        end

        it 'a name' do
          a = SchemaAttribute.first(term: 'http://purl.org/dc/terms/format')
          expect(a.name).to eq 'format'
        end

        it 'an alt_name' do
          a = SchemaAttribute.first(term: 'http://purl.org/dc/terms/format')
          expect(a.alt_name).to eq 'format'
        end

        context 'the index of the column in the DwCA source file' do
          it 'an integer for the index if there is one' do
            expect(SchemaAttribute.first(name: 'access_uri').index).to be 2
          end

          it 'nil if there is no index' do
            expect(SchemaAttribute.first(alt_name: 'rights!').index).to be_nil
          end
        end

        context 'the default value' do
          it 'the default value for the column' do
            a = SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights')
            expect(a.default).to eq '© 2008 XY Museum'
          end

          it 'nil if there is no default value' do
            a = SchemaAttribute.first(name: 'access_uri')
            expect(a.default).to be_nil
          end
        end
      end

      context 'returns the length of the column equal to' do
        it 'the length of the default value' do
          a1 = SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights')
          expect(a1.length).to be 16
        end

        it 'the maximum content length if given and no default set' do
          attr = SchemaAttribute.first(name: 'coreid')
          attr.max_content_length = 32
          expect(attr.length).to be 32
        end

        it 'the maximum content length if given and larger than the default' do
          attr = SchemaAttribute.first(alt_name: 'rights!')
          attr.max_content_length = 100
          expect(attr.length).to be 100
        end

        it 'the default length if longer than a given max content length' do
          attr = SchemaAttribute.first(alt_name: 'rights!')
          attr.max_content_length = 20
          expect(attr.length).to be 53
        end

        it 'nil if there is no default value' do
          expect(SchemaAttribute.first(name: 'coreid').length).to be_nil
        end
      end

      context 'returns indexing options' do
        it 'returns false if the column should not be indexed' do
          expect(SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights')
                                .index_options).to be_falsey
        end

        it 'returns true if the column should be indexed' do
          expect(SchemaAttribute.first(name: 'coreid')
                                .index_options).to be_truthy
        end

        it 'returns a unique index as a hash option' do
          attr = SchemaAttribute.first(term: 'http://purl.org/dc/terms/rights')
          attr.has_index = true
          attr.is_unique = true
          expect(attr.index_options).to include(unique: true)
        end
      end
    end
  end
end
