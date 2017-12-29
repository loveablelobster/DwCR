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
      xml = <<-HEREDOC
<?xml version="1.0" ?>
<archive>
	<core rowType="http://rs.tdwg.org/dwc/terms/Occurrence">
		<id index="0"/>
	</core>
	<extension rowType="http://rs.tdwg.org/ac/terms/Multimedia">
		<coreid index="0"/>
		<field index="1" term="http://example.org/terms/aTerm"/>
		<field index="2" term="http://example.org/terms/bTerm"/>
		<field default="b default" term="http://example.org/terms/bTerm"/>
		<field default="c default" term="http://example.org/terms/cTerm"/>
	</extension>
</archive>
HEREDOC

      @db = ArchiveStore.instance.connect
      DwCR.parse_meta(Nokogiri::XML(xml)).last[:schema_attributes]
                                         .map { |s| SchemaAttribute.create(s) }
    end

    context 'upon initialization it presists' do
      it 'the default column type `string`' do
      	expect(SchemaAttribute.first(name: 'a_term').type).to eq 'string'
      end

      context 'the index of the column in the DwCA source file' do
        it 'an integer for the index if there is one' do
          expect(SchemaAttribute.first(name: 'a_term').index).to be 1
        end

        it 'nil if there is no index' do
          expect(SchemaAttribute.first(name: 'c_term').index).to be_nil
        end
      end
    end

    it 'returns the column name for the schema as symbol' do
      expect(SchemaAttribute.first(name: 'a_term').column_name).to be :a_term
    end

    it 'returns the schema for creation of the column' do
      f = SchemaAttribute.first(name: 'coreid')
      a = SchemaAttribute.first(name: 'a_term')
      b = SchemaAttribute.first(name: 'b_term')
      c = SchemaAttribute.first(name: 'c_term')
      expect(f.column_schema).to eq([:coreid,
                                     :string,
                                     { index: true, default: nil }])
      expect(a.column_schema).to eq([:a_term,
                                     :string,
                                     { index: false, default: nil }])
      expect(b.column_schema).to eq([:b_term,
                                     :string,
                                     { index: false, default: 'b default' }])
      expect(c.column_schema).to eq([:c_term,
                                     :string,
                                     { index: false, default: 'c default' }])
    end

    context 'returns the length of the column equal to' do
      it 'the length of the default value' do
        expect(SchemaAttribute.first(name: 'b_term').length).to be 9
      end

      it 'the maximum content length if given and no default set' do
        a = SchemaAttribute.first(name: 'a_term')
        a.max_content_length = 32
        expect(a.length).to be 32
      end

      it 'the maximum content length if given and larger than the default' do
        b = SchemaAttribute.first(name: 'b_term')
        b.max_content_length = 100
        expect(b.length).to be 100
      end

      it 'the default length if longer than a given max content length' do
        b = SchemaAttribute.first(alt_name: 'b_term')
        b.max_content_length = 8
        expect(b.length).to be 9
      end

      it 'nil if there is no default value' do
        expect(SchemaAttribute.first(name: 'a_term').length).to be_nil
      end
    end

    context 'returns indexing options' do
      it 'returns false if the column should not be indexed' do
        expect(SchemaAttribute.first(name: 'a_term')
                              .index_options).to be_falsey
      end

      it 'returns true if the column should be indexed' do
        expect(SchemaAttribute.first(name: 'coreid')
                              .index_options).to be_truthy
      end

      it 'returns a unique index as a hash option' do
        a = SchemaAttribute.first(name: 'a_term')
        a.has_index = true
        a.is_unique = true
        expect(a.index_options).to include(unique: true)
      end
    end
  end
end
