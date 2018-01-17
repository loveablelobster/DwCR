# frozen_string_literal: true

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

  RSpec.describe 'MetaEntity' do
    it 'has a symbol for the `table_name`' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      expect(meta_entity.table_name).to be :items
    end

    context 'has one or many columns' do
      it 'gets the columns' do
        meta_entity = MetaEntity.create(term: 'example.org/item')
        meta_entity.add_meta_attribute(term: 'example.org/termA',
                                       name: 'term_a')
        meta_entity.add_meta_attribute(term: 'example.org/termB',
                                       name: 'term_b')
        expect(meta_entity.meta_attributes.size).to be 2
      end

      it 'returns the key for the core' do
        meta_entity = MetaEntity.create(term: 'example.org/item',
                                        is_core: true,
                                        key_column: 0)
        meta_entity.add_meta_attribute(name: 'key_term', index: 0)
        expect(meta_entity.key).to be :key_term
      end

      it 'returns the key for extensions' do
        meta_entity = MetaEntity.create(term: 'example.org/item',
                                        is_core: false,
                                        key_column: 1)
        meta_entity.add_meta_attribute(name: 'foreign_key', index: 1)
        expect(meta_entity.key).to be :foreign_key
      end

      it 'ensures the `name` is unique' do
        meta_entity = MetaEntity.create(term: 'example.org/item')
        a = meta_entity.add_meta_attribute(name: 'term')
        b = meta_entity.add_meta_attribute(name: 'term')
        expect(a.name == b.name).to be_falsey
        expect(a.name).to eq 'term'
        expect(b.name).to eq 'term!'
      end
    end

    it 'gets the names of the contents files' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      meta_entity.add_content_file(name: 'file_a.csv')
      meta_entity.add_content_file(name: 'file_b.csv')
      file_names = meta_entity.content_files.map(&:name)
      expect(file_names).to include('file_a.csv', 'file_b.csv')
    end

    it 'returns a list of alt_names as content headers, sorted by index' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      meta_entity.add_meta_attribute(name: 'term_b', index: 2)
      meta_entity.add_meta_attribute(name: 'term_a', index: 1)
      expect(meta_entity.content_headers).to contain_exactly(:term_a, :term_b)
    end
  end
end
