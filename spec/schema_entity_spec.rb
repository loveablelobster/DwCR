# frozen_string_literal: true

require_relative '../lib/db/connection'
require_relative '../lib/store/metaschema'

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

  RSpec.describe 'SchemaEntity' do
    it 'has a symbol for the `table_name`' do
      schema_entity = SchemaEntity.create(name: 'items')
      expect(schema_entity.table_name).to be :items
    end

    context 'has one or many columns' do
      it 'gets the columns' do
        schema_entity = SchemaEntity.create(name: 'item')
        schema_entity.add_schema_attribute(term: 'example.org/termA')
        schema_entity.add_schema_attribute(term: 'example.org/termB')
        expect(schema_entity.schema_attributes.size).to be 2
      end

      it 'returns the key for the core' do
        schema_entity = SchemaEntity.create(name: 'item',
                                            is_core: true,
                                            key_column: 0)
        schema_entity.add_schema_attribute(name: 'term', index: 0)
        expect(schema_entity.key).to be :term
      end

      it 'returns the key for extensions' do
        schema_entity = SchemaEntity.create(name: 'item',
                                            is_core: false,
                                            key_column: 1)
        schema_entity.add_schema_attribute(name: 'foreign_key', index: 1)
        expect(schema_entity.key).to be :foreign_key
      end

      it 'ensures the `name` is unique' do pending 'not implemented'
#         SchemaAttribute.create(name: 'term')
#         expect { SchemaAttribute.create(name: 'term') }
#           .to raise_error Sequel::UniqueConstraintViolation
      end
    end

    it 'gets the names of the contents files' do
      schema_entity = SchemaEntity.create(name: 'item')
      schema_entity.add_content_file(name: 'file_a.csv')
      schema_entity.add_content_file(name: 'file_b.csv')
      file_names = schema_entity.content_files.map(&:name)
      expect(file_names).to include('file_a.csv', 'file_b.csv')
    end

    it 'returns a list of alt_names as content headers, sorted by index' do
      schema_entity = SchemaEntity.create(name: 'item')
      schema_entity.add_schema_attribute(name: 'term_b', index: 2)
      schema_entity.add_schema_attribute(name: 'term_a', index: 1)
      expect(schema_entity.content_headers).to contain_exactly(:term_a, :term_b)
    end
  end
end
