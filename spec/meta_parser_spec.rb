# frozen_string_literal: true

require 'psych'

require_relative '../lib/meta_parser'

#
module DwCR
  RSpec.describe 'Methods that parse the meta xml and return' do
    before(:all) do
      xml = <<-HEREDOC
<?xml version="1.0" ?>
<archive xmlns="http://rs.tdwg.org/dwc/text/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://rs.tdwg.org/dwc/text/ http://rs.tdwg.org/dwc/text/tdwg_dwc_text.xsd">
	<core fieldsEnclosedBy="&quot;" fieldsTerminatedBy="," linesTerminatedBy="\r\n" rowType="http://rs.tdwg.org/dwc/terms/Occurrence">
		<files>
			<location>occurrence.csv</location>
		</files>
		<id index="0"/>
		<field index="0" term="http://rs.tdwg.org/dwc/terms/occurrenceID"/>
		<field index="1" term="http://rs.tdwg.org/dwc/terms/catalogNumber"/>
		<field default="NHMD" term="http://rs.tdwg.org/dwc/terms/institutionCode"/>
	</core>
	<extension fieldsEnclosedBy="&quot;" fieldsTerminatedBy="," linesTerminatedBy="\r\n" rowType="http://rs.tdwg.org/ac/terms/Multimedia">
		<files>
			<location>media.csv</location>
		</files>
		<coreid index="0"/>
		<field index="1" term="http://purl.org/dc/terms/identifier"/>
		<field index="2" term="http://rs.tdwg.org/ac/terms/accessURI"/>
		<field index="6" term="http://purl.org/dc/terms/rights"/>
		<field default="© 2008 XY Museum" term="http://purl.org/dc/terms/rights"/>
		<field default="http://creativecommons.org/licenses/by/4.0/deed.en_US" term="http://purl.org/dc/elements/1.1/rights"/>
	</extension>
</archive>
HEREDOC
      @meta = Nokogiri::XML(xml)
      @parsed_meta = DwCR.parse_meta(Nokogiri::XML(xml))
    end

    let(:core) { @parsed_meta.first }
    let(:media) { @parsed_meta.last }

    it 'an array of hashes:' do
      expect(DwCR.parse_meta(@meta).size).to be 2
      expect(DwCR.parse_meta(@meta).map(&:class)).to contain_exactly(Hash, Hash)
    end

    context 'the core' do
      it 'has the `is_core` flag set' do
        expect(core).to include :is_core => true
      end

      it 'has a pluralized `name`' do
        expect(core).to include :name => 'occurrence'.pluralize
      end

      it 'has a URL defining the `term`' do
        expect(core).to include :term => 'http://rs.tdwg.org/dwc/terms/Occurrence'
      end

      it 'has the index of the `key_column`' do
        expect(core).to include :key_column => 0
      end

      context 'has the definitions for `fields`' do
        it 'has an array of hashes' do
          expect(core[:schema_attributes].size).to be 3
          expect(core[:schema_attributes].map(&:class)).to contain_exactly(Hash, Hash, Hash)
        end

        context 'each field' do
          it 'has a `term`' do
            expect(core[:schema_attributes].map { |f| f[:term] }).to contain_exactly('http://rs.tdwg.org/dwc/terms/occurrenceID',
                                                                          'http://rs.tdwg.org/dwc/terms/catalogNumber',
                                                                          'http://rs.tdwg.org/dwc/terms/institutionCode')
          end

          it 'has a `name`' do
            expect(core[:schema_attributes].map { |f| f[:name] }).to contain_exactly('occurrence_id',
                                                                          'catalog_number',
                                                                          'institution_code')
          end

          context 'has an `index`' do
            it 'with an integer of the column in the source file(s)' do
              expect(core[:schema_attributes][0...2].map { |f| f[:index] }).to eq([0, 1])
            end

            it 'or nil if the field is not in the source file(s)' do
              expect(core[:schema_attributes].last[:index]).to be_nil
            end
          end

          context 'has a `default`' do
            it 'with a default value for the column' do
              expect(core[:schema_attributes].last[:default]).to eq('NHMD')
            end

            it 'or nil if the field does not have a default value' do
              expect(core[:schema_attributes][0...2].map { |f| f[:default] }).to contain_exactly(nil, nil)
            end
          end

          context 'has a boolean `has_index` flag' do
            it 'that is false for every field except the `key_column`' do
              expect(core[:schema_attributes][1..2].map { |f| f[:has_index] }).to contain_exactly(false, false)
            end

            it 'that is true for the `key_column`' do
              expect(core[:schema_attributes].first[:has_index]).to be_truthy
            end
          end

          context 'has a boolean `is_unique` flag' do
            it 'that is false for every field except the `key_column`' do
              expect(core[:schema_attributes][1..2].map { |f| f[:is_unique] }).to contain_exactly(false, false)
            end

            it 'that is true for the `key_column`' do
              expect(core[:schema_attributes].first[:is_unique]).to be_truthy
            end
          end
        end
      end

      context 'has the information on the content_files' do
        it 'has an array of hashes' do
          expect(core[:content_files].size).to be 1
          expect(core[:content_files].map(&:class)).to contain_exactly(Hash)
        end

        it 'has the names of the content_files' do
          expect(core[:content_files].first[:name]).to eq'occurrence.csv'
        end
      end
    end

    context 'one extension' do
      it 'has the `is_core` flag not set' do
        expect(media).to include :is_core => false
      end

      it 'has a pluralized `name`' do
        expect(media).to include :name => 'multimedia'.pluralize
      end

      it 'has a URL defining the `term`' do
        expect(media).to include :term => 'http://rs.tdwg.org/ac/terms/Multimedia'
      end

      it 'has the index of the `key_column`' do
        expect(media).to include :key_column => 0
      end

      context 'has the definitions for `fields`' do
        it 'has an array of hashes' do
          attrs = media[:schema_attributes]
          expect(attrs.size).to be 5
          expect(attrs.map(&:class).uniq).to contain_exactly(Hash)
        end

        context 'each field' do
          it 'has a `term`' do
            expect(media[:schema_attributes].map { |f| f[:term] }).to contain_exactly(nil,
                                                                                      'http://purl.org/dc/terms/identifier',
                                                                                      'http://rs.tdwg.org/ac/terms/accessURI',
                                                                                      'http://purl.org/dc/terms/rights',
                                                                                      'http://purl.org/dc/elements/1.1/rights')
          end

          it 'has a `name` that is suffixed with `!` where equivocal' do
            expect(media[:schema_attributes].map { |f| f[:name] }).to contain_exactly('coreid',
                                                                                      'identifier',
                                                                                      'access_uri',
                                                                                      'rights',
                                                                                      'rights!')
          end

          context 'has an `index`' do
            it 'with an integer of the column in the source file(s)' do
              attrs = media[:schema_attributes][0...4]
              expect(attrs.map { |f| f[:index] }).to eq([0, 1, 2, 6])
            end

            it 'or nil if the field is not in the source file(s)' do
              expect(media[:schema_attributes].last[:index]).to be_nil
            end
          end

          context 'has a `default`' do
            it 'with a default value for the column' do
              attrs = media[:schema_attributes]
              defs = attrs[3...5].map { |f| f[:default] }
              exp = ['© 2008 XY Museum',
                     'http://creativecommons.org/licenses/by/4.0/deed.en_US']
              expect(defs).to contain_exactly(*exp)
            end

            it 'or nil if the field does not have a default value' do
              attrs = media[:schema_attributes]
              no_defs = attrs[0...3].map { |f| f[:default] }
              expect(no_defs).to eq([nil, nil, nil])
            end
          end

          context 'has a boolean `has_index` flag' do
            it 'that is false for every field except the `key_column`' do
              attrs = media[:schema_attributes]
              false_indices = attrs[1...5].map { |f| f[:has_index] }
              expect(false_indices.uniq).to contain_exactly(false)
            end

            it 'that is true for the `key_column`' do
              expect(media[:schema_attributes].first[:has_index]).to be_truthy
            end
          end

          it 'has a boolean `is_unique` flag for the index' do
            uniques = media[:schema_attributes].map { |f| f[:is_unique] }
            expect(uniques.uniq).to contain_exactly(false)
          end
        end
      end

      context 'has the information on the content_files' do
        it 'has an array of hashes' do
          expect(media[:content_files].size).to be 1
          expect(media[:content_files].map(&:class)).to contain_exactly(Hash)
        end

        it 'has the names of the content_files' do
          expect(media[:content_files].first[:name]).to eq 'media.csv'
        end
      end
    end
  end
end
