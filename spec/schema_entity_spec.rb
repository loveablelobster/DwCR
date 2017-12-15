# frozen_string_literal: true

require_relative '../lib/archive_store'
require_relative '../lib/meta_parser'

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false
  end

  RSpec.describe 'SchemaEntity' do
    before(:all) do
      db = ArchiveStore.instance.connect()
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      parsed_meta = DwCR.parse_meta(doc)
      @core = DwCR.create_schema_entity(parsed_meta.first)
      @media = DwCR.create_schema_entity(parsed_meta.last)
    end

    context 'determines the kind' do
      it 'determines the kind' do
        expect(@core[:is_core]).to be true
        expect(@media[:is_core]).to be false

        # FIXME: necessary ?
        expect(@core.kind).to be :core
        expect(@media.kind).to be :extension
      end
#
#       it 'raises and exception if the kind is invalid' do
#         expect { SchemaEntity.new(@doc.css('invalid').first) }.to raise_error(RuntimeError, 'invalid node: invalid')
#       end
    end

    it 'has a URL as string for the `term`' do
      expect(@core.term).to eq 'http://rs.tdwg.org/dwc/terms/Occurrence'
      expect(@media.term).to eq 'http://rs.tdwg.org/ac/terms/Multimedia'
    end

    it 'derives pluralized extension name as symbol from the term' do
      expect(@core.name).to eq 'occurrences'
      expect(@media.name).to eq 'multimedia'
    end

    it 'has a symbol for the `table_name`' do
    	expect(@core.table_name).to eq :occurrences
    	expect(@media.table_name).to eq :multimedia
    end

    context 'gets the columns' do
      it 'gets the columns' do
        expect(@core.schema_attributes[0].values).to include(:term => 'http://rs.tdwg.org/dwc/terms/occurrenceID',
                                                             :name => 'occurrence_id',
                                                             :alt_name => 'occurrence_id',
                                                             :index => 0,
                                                             :has_index => true,
                                                             :is_unique => true)
        expect(@core.schema_attributes[1].values).to include(:term => 'http://rs.tdwg.org/dwc/terms/catalogNumber',
                                                             :name => 'catalog_number',
                                                             :alt_name => 'catalog_number',
                                                             :index => 1,
                                                             :has_index => false,
                                                             :is_unique => false)
        expect(@media.schema_attributes[0].values).to include(:term => nil,
                                                              :name => 'coreid',
                                                              :alt_name => 'coreid',
                                                              :index => 0,
                                                              :has_index => true,
                                                              :is_unique => false)
        expect(@media.schema_attributes[1].values).to include(:term => 'http://purl.org/dc/terms/identifier',
                                                              :name => 'identifier',
                                                              :alt_name => 'identifier',
                                                              :index => 1,
                                                              :has_index => false,
                                                              :is_unique => false)
      end

      it 'has unique column names' do
        alt_names = @media.schema_attributes
                          .map(&:values)
                          .map { |v| v[:alt_name] }
        expect(alt_names.size).to eq(alt_names.uniq.size)
      end

      it 'has default values where present' do
        expect(@media.schema_attributes[6].default).to eq '© 2008 XY Museum'
      end

      # FIXME: necessary ?
      it 'has the key for the core' do
        expect(@core.key_column).to be 0
        expect(@core.key).to include(primary: 'occurrence_id')
      end

      it 'has the key extensions' do
      	expect(@media.key).to eq(foreign: 'coreid')
      end
    end

    it 'gets the names of the contents files' do
    	expect(@core.content_files.first.name).to eq 'occurrence.csv'
    	expect(@media.content_files.first.name).to eq 'media.csv'
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
      expect(@core.schema_attributes[0].column_schema).to eq([:occurrence_id, :string, { index: { unique: true }, default: nil }])
      expect(@media.schema_attributes[0].column_schema).to eq([:coreid, :string, { index: true, default: nil }])
    end
#
#     it 'updates the attribute lengths' do
#       @media.update(coreid: 20, identifier: 20,
#                     access_uri: 20,
#                     title: 20,
#                     format: 20,
#                     owner: 20,
#                     rights: 20,
#                     license_logo_url: 20,
#                     credit: 20)
#       expect(@media.attributes.map(&:length)).to eq([20, 20, 20, 20, 20, 20, 20, 20, 20, 53])
#     end
  end
end
