# frozen_string_literal: true

require_relative 'support/models_shared_context'

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around(:each) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'MetaAttribute' do
    include_context 'Models helpers'

    context 'upon initialization' do
      it 'the `type` attribute defaults to `string`' do
        meta_attribute = MetaAttribute.create(term: 'example.org/term',
                                                  name: 'term')
        expect(meta_attribute.type).to eq 'string'
      end
    end

    it 'returns the column name for the schema as symbol' do
      meta_attribute = MetaAttribute.create(name: 'term')
      expect(meta_attribute.column_name).to be :term
    end

    context 'returns an array with `column_params` to create the column' do
      it 'with name and type' do
        entity = archive.add_meta_entity(name: 'item')
        params = [:term, :string, { index: false, default: nil }]
        attribute = entity.add_meta_attribute(name: 'term')
        expect(attribute.to_table_column).to eq(params)
      end

      it 'with name, type and default' do
        entity = archive.add_meta_entity(name: 'item')
        params = [:term, :string, { index: false, default: 'default' }]
        attribute = entity.add_meta_attribute(name: 'term',
                                                default: 'default')
        expect(attribute.to_table_column).to eq(params)
      end

      it 'with name, type and index' do
        entity = archive.add_meta_entity(name: 'item', key_column: 0)
        params = [:term, :string, { index: true, default: nil }]
        attribute = entity.add_meta_attribute(name: 'term',
                                                index: 0)
        expect(attribute.to_table_column).to eq(params)
      end

      it 'with name, type and unique index' do
        entity = archive.add_meta_entity(name: 'item', key_column: 0, is_core: true)
        params = [:term, :string, { index: { unique: true }, default: nil }]
        attribute = entity.add_meta_attribute(name: 'term',
                                                index: 0)
        expect(attribute.to_table_column).to eq(params)
      end
    end

    context 'returns the length of the column equal to' do
      it 'the length of the default value' do
        meta_attribute = MetaAttribute.create(name: 'term',
                                                  default: 'default')
        expect(meta_attribute.length).to be 7
      end

      it 'the maximum content length if given and no default set' do
        meta_attribute = MetaAttribute.create(name: 'term')
        meta_attribute.max_content_length = 10
        expect(meta_attribute.length).to be 10
      end

      it 'the maximum content length if given and larger than the default' do
        meta_attribute = MetaAttribute.create(name: 'term',
                                                  default: 'default')
        meta_attribute.max_content_length = 10
        expect(meta_attribute.length).to be 10
      end

      it 'the default length if longer than a given max content length' do
        meta_attribute = MetaAttribute.create(name: 'term',
                                                  default: 'default')
        meta_attribute.max_content_length = 5
        expect(meta_attribute.length).to be 7
      end

      it 'nil if there is no default value' do
        meta_attribute = MetaAttribute.create(name: 'term')
        expect(meta_attribute.length).to be_nil
      end
    end
  end
end
