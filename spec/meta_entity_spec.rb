# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around(:each) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'MetaEntity' do
    it 'inserts a default name that is the terminal of the term' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      expect(meta_entity.name).to eq 'item'
    end

    it 'has a symbol for the `table_name`' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      expect(meta_entity.table_name).to be :items
    end

    context 'has one or many columns' do
      it 'gets the columns' do
        meta_entity = MetaEntity.create(term: 'example.org/item')
        meta_entity.add_meta_attribute(term: 'example.org/termA')
        meta_entity.add_meta_attribute(term: 'example.org/termB')
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

      it 'auto generates a name for a column from the term' do
        meta_entity = MetaEntity.create(term: 'example.org/item')
        a = meta_entity.add_meta_attribute(term: 'example.org/termA')
        expect(a.name).to eq 'term_a'
      end

      it 'rasies an error if there is neither name nor term' do
        meta_entity = MetaEntity.create(term: 'example.org/item')
        expect { meta_entity.add_meta_attribute(index: 0) }.to raise_error Sequel::NotNullConstraintViolation
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

    it 'gets the names of the content files' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      meta_entity.add_content_file(name: 'file_a.csv')
      meta_entity.add_content_file(name: 'file_b.csv')
      file_names = meta_entity.content_files.map(&:name)
      expect(file_names).to include('file_a.csv', 'file_b.csv')
    end
  end
end
