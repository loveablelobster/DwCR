# frozen_string_literal: true

require_relative 'support/models_shared_context'

#
module DwCR
  RSpec.describe 'MetaAttribute' do
    include_context 'Models helpers'

    let(:attribute) { MetaAttribute.create(name: 'term') }

    it 'returns the column name as symbol' do
      expect(attribute.column_name).to be :term
    end

    context 'when returning whether a field is foreign key' do
      let :attrs do
        e = entity(key_column: 0, with_attributes: [{ name: 'key', index: 0 },
                                                    { name: 'term', index: 1 }])
        e.meta_attributes
      end

      it 'returns tyrue if the attribute is the entities key_column' do
        expect(attrs.first.foreign_key?).to be_truthy
      end

      it 'returns false if the attribute is not the entities key_column' do
        expect(attrs.last.foreign_key?).to be_falsey
      end
    end

    context 'when returning the length of the column, length is' do
      it 'the length of the default value if no content length given' do
        meta_attribute = MetaAttribute.create(name: 'term', default: 'default')
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
        meta_attribute = MetaAttribute.create(name: 'term', default: 'default')
        meta_attribute.max_content_length = 5
        expect(meta_attribute.length).to be 7
      end

      it 'nil if there is no default value' do
        meta_attribute = MetaAttribute.create(name: 'term')
        expect(meta_attribute.length).to be_nil
      end
    end

    context 'when returning the table column args' do
      let :attrs do
        entity(key_column: 0, with_attributes: [
                 { name: 'column' },
                 { name: 'column_with_default', default: 'default' },
                 { name: 'key_column', index: 0 }
               ]).meta_attributes
      end

      it 'has name and type' do
        expect(attrs[0].to_table_column)
          .to match_array [:column, :string, { index: false, default: nil }]
      end

      it 'has name, type and default if default is given' do
        expect(attrs[1].to_table_column)
          .to match_array [:column_with_default, :string,
                           { index: false, default: 'default' }]
      end

      it 'has name, type and index if index is given' do
        expect(attrs[2].to_table_column)
          .to match_array [:key_column, :string, { index: true, default: nil }]
      end

      it 'has name, type and unique index' do
        attrs[2].meta_entity.is_core = true
        expect(attrs[2].to_table_column)
          .to match_array [:key_column, :string,
                           { index: { unique: true }, default: nil }]
      end
    end
  end
end
