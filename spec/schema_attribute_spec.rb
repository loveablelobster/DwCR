# frozen_string_literal: true

require_relative '../lib/db/connection'
require_relative '../lib/store/metaschema'
require_relative '../lib/meta_parser'
#
module DwCR
  RSpec.configure do |config|
    config.warnings = false
  end

  RSpec.describe 'SchemaAttribute' do
    before(:all) do
      xml = <<~HEREDOC
        <?xml version="1.0" ?>
        <archive>
          <core rowType="http://example.org/terms/Core">
            <id index="0"/>
            <field index="0" term="http://example.org/terms/theID"/>
          </core>
          <extension rowType="http://example.org/ac/terms/Extension">
            <coreid index="0"/>
            <field index="1" term="http://example.org/terms/aTerm"/>
            <field index="2" term="http://example.org/terms/bTerm"/>
            <field default="b default" term="http://example.org/terms/bTerm"/>
            <field default="c default" term="http://example.org/terms/cTerm"/>
          </extension>
        </archive>
HEREDOC

      DwCR.parse_meta(Nokogiri::XML(xml))
          .each do |node|
            node[:schema_attributes].map { |s| SchemaAttribute.create(s) }
          end
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
      k = SchemaAttribute.first(name: 'the_id')
      f = SchemaAttribute.first(name: 'coreid')
      a = SchemaAttribute.first(name: 'a_term')
      b = SchemaAttribute.first(name: 'b_term')
      c = SchemaAttribute.first(name: 'c_term')
      expect(k.column_params).to eq([:the_id,
                                     :string,
                                     { index: { unique: true }, default: nil }])
      expect(f.column_params).to eq([:coreid,
                                     :string,
                                     { index: true, default: nil }])
      expect(a.column_params).to eq([:a_term,
                                     :string,
                                     { index: false, default: nil }])
      expect(b.column_params).to eq([:b_term,
                                     :string,
                                     { index: false, default: 'b default' }])
      expect(c.column_params).to eq([:c_term,
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

    after(:all) do
      SchemaAttribute.dataset.destroy
    end
  end
end
