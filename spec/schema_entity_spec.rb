# frozen_string_literal: true

require_relative '../lib/db/connection'
require_relative '../lib/store/metaschema'
require_relative '../lib/meta_parser'

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false
  end

  RSpec.describe 'SchemaEntity' do
    before(:all) do
      xml = <<~HEREDOC
        <?xml version="1.0" ?>
        <archive>
          <core rowType="http://example.org/terms/CoreItem">
          	<files>
			        <location>core_file.csv</location>
		        </files>
            <id index="0"/>
            <field index="0" term="http://example.org/terms/theID"/>
          </core>
          <extension rowType="http://example.org/ac/terms/ExtensionItem">
            <files>
			        <location>extension_file.csv</location>
		        </files>
            <coreid index="0"/>
            <field index="1" term="http://example.org/terms/aTerm"/>
            <field index="2" term="http://example.org/terms/bTerm"/>
            <field default="b default" term="http://example.org/terms/bTerm"/>
            <field default="c default" term="http://example.org/terms/cTerm"/>
          </extension>
        </archive>
HEREDOC
      @db = DwCR.connect
      DwCR.create_metaschema
      parsed_meta = DwCR.parse_meta(Nokogiri::XML(xml))
      @core = DwCR.create_schema_entity(parsed_meta.first)
      @extension = DwCR.create_schema_entity(parsed_meta.last)
    end

    context 'determines the kind' do
      it 'determines the kind' do
        expect(@core[:is_core]).to be true
        expect(@extension[:is_core]).to be false
      end
    end

    it 'has a URL as string for the `term`' do
      expect(@core.term).to eq 'http://example.org/terms/CoreItem'
      expect(@extension.term).to eq 'http://example.org/ac/terms/ExtensionItem'
    end

    it 'derives pluralized extension name as symbol from the term' do
      expect(@core.name).to eq 'core_items'
      expect(@extension.name).to eq 'extension_items'
    end

    it 'has a symbol for the `table_name`' do
      expect(@core.table_name).to eq :core_items
      expect(@extension.table_name).to eq :extension_items
    end

    context 'gets the columns' do
      it 'gets the columns' do
        cc = @core.schema_attributes[0].values
        expect(cc).to include(term: 'http://example.org/terms/theID',
                              name: 'the_id', alt_name: 'the_id',
                              index: 0, has_index: true, is_unique: true)
      end

      it 'has unique column names' do
        alt_names = @extension.schema_attributes
                          .map(&:values)
                          .map { |v| v[:alt_name] }
        expect(alt_names.size).to eq(alt_names.uniq.size)
      end

      it 'has the key for the core' do
        expect(@core.key_column).to be 0
        expect(@core.key).to be :the_id
      end

      it 'has the key extensions' do
        expect(@extension.key_column).to be 0
        expect(@extension.key).to be :coreid
      end
    end

    it 'gets the names of the contents files' do
      expect(@core.content_files.first.name).to eq 'core_file.csv'
      expect(@extension.content_files.first.name).to eq 'extension_file.csv'
    end

    it 'returns a list of alt_names as content headers, sorted by index' do
      expect(@extension.content_headers).to contain_exactly(:coreid,
                                                        :a_term,
                                                        :b_term)
    end

    after(:all) do
      @core.destroy
      @extension.destroy
    end
  end
end
