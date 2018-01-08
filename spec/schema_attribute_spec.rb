# frozen_string_literal: true

require_relative '../lib/db/connection'
require_relative '../lib/store/metaschema'
require_relative '../lib/meta_parser'
#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around(:each) do |example|
      Sequel::Model.db
                    .transaction(rollback: :always,
                                 auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'SchemaAttribute' do
    context 'upon initialization' do
      it 'the `type` attribute defaults to `string`' do
        schema_attribute = SchemaAttribute.create(term: 'example.org/term')
        expect(schema_attribute.type).to eq 'string'
      end

      it 'ensures the `name` is unique' do
        SchemaAttribute.create(name: 'term')
        expect { SchemaAttribute.create(name: 'term') }
          .to raise_error Sequel::UniqueConstraintViolation
      end
    end

    it 'returns the column name for the schema as symbol' do
      schema_attribute = SchemaAttribute.create(name: 'term')
      expect(schema_attribute.column_name).to be :term
    end

    context 'returns an array with `column_params` to create the column' do
      it 'with name and type' do
        params = [:term, :string, { index: false, default: nil }]
        schema_attribute = SchemaAttribute.create(name: 'term')
        expect(schema_attribute.column_params).to eq(params)
      end

      it 'with name, type and default' do
        params = [:term, :string, { index: false, default: 'default' }]
        schema_attribute = SchemaAttribute.create(name: 'term',
                                                  default: 'default')
        expect(schema_attribute.column_params).to eq(params)
      end

      it 'with name, type and index' do
        params = [:term, :string, { index: true, default: nil }]
        schema_attribute = SchemaAttribute.create(name: 'term',
                                                  has_index: true)
        expect(schema_attribute.column_params).to eq(params)
      end

      it 'with name, type and unique index' do
        params = [:term, :string, { index: { unique: true }, default: nil }]
        schema_attribute = SchemaAttribute.create(name: 'term',
                                                  has_index: true,
                                                  is_unique: true)
        expect(schema_attribute.column_params).to eq(params)
      end
    end

    context 'returns the length of the column equal to' do
      it 'the length of the default value' do
        schema_attribute = SchemaAttribute.create(name: 'term',
                                                  default: 'default')
        expect(schema_attribute.length).to be 7
      end

      it 'the maximum content length if given and no default set' do
        schema_attribute = SchemaAttribute.create(name: 'term')
        schema_attribute.max_content_length = 10
        expect(schema_attribute.length).to be 10
      end

      it 'the maximum content length if given and larger than the default' do
        schema_attribute = SchemaAttribute.create(name: 'term',
                                                  default: 'default')
        schema_attribute.max_content_length = 10
        expect(schema_attribute.length).to be 10
      end

      it 'the default length if longer than a given max content length' do
        schema_attribute = SchemaAttribute.create(name: 'term',
                                                  default: 'default')
        schema_attribute.max_content_length = 5
        expect(schema_attribute.length).to be 7
      end

      it 'nil if there is no default value' do
        schema_attribute = SchemaAttribute.create(name: 'term')
        expect(schema_attribute.length).to be_nil
      end
    end
  end
end
