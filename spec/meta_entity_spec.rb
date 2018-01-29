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

  RSpec.describe 'MetaEntity' do
    include_context 'Models helpers'

    context 'when creating new instances' do
      it 'throws an error if the core is not associated with an archive' do
        m = 'ArgumentError:'\
            ' MetaEntity instances need to belong to a MetaArchive'
        expect { MetaEntity.create(term: 'example.org/DanglingItem') }
          .to raise_error(Sequel::DatabaseError, m)
      end

      it 'inserts name from last component of term (lowercase, underscore)' do
        meta_entity = archive.add_meta_entity(term: 'example.org/AnItem')
        expect(meta_entity.name).to eq 'an_item'
      end
    end

    context 'when adding extensions to the core' do
      it 'throws an error if the core is not associated with an archive' do
        extension = archive.add_meta_entity(term: 'example.org/XtnItem')
      	expect { extension.add_extension(term: 'example.org/NestedXtn') }
      	  .to raise_error(ArgumentError,
      	                  'extensions must be associated with a core')
      end

      it 'associates the extension with the archive' do
        extension = core_in(archive).add_extension(term: 'example.org/XtnItem')
        expect(extension.meta_archive).to be archive
      end

    	it 'sets the is_core flag to false' do
        extension = core_in(archive).add_extension(term: 'example.org/XtnItem')
        expect(extension.is_core).to be_falsey
    	end
    end

    context 'when adding MetaAttributes (columns)' do
      it 'ensures the column name is unique' do
        meta_entity = archive.add_meta_entity(term: 'example.org/item')
        a = meta_entity.add_meta_attribute(name: 'term')
        b = meta_entity.add_meta_attribute(name: 'term')
        expect(a.name == b.name).to be_falsey
      end

      it 'suffixs subsequent occurrences of a term with !' do
        meta_entity = archive.add_meta_entity(term: 'example.org/item')
        a = meta_entity.add_meta_attribute(name: 'term')
        b = meta_entity.add_meta_attribute(name: 'term')
        expect(b.name).to eq 'term!'
      end
    end

    # class name

    # files

    # loaded?

    # foreign_key

    # key

    # model_associations

    # model_get

    # table_name

    # update_meta_attributes!

    # add_attribute_from

    # add_files_from

    it 'has a symbol for the `table_name`' do
      meta_entity = archive.add_meta_entity(term: 'example.org/item')
      expect(meta_entity.table_name).to be :items
    end

    context 'has one or many columns' do
      it 'gets the columns' do
        meta_entity = archive.add_meta_entity(term: 'example.org/item')
        meta_entity.add_meta_attribute(term: 'example.org/termA')
        meta_entity.add_meta_attribute(term: 'example.org/termB')
        expect(meta_entity.meta_attributes.size).to be 2
      end

      it 'returns the key for the core' do
        meta_entity = archive.add_meta_entity(term: 'example.org/item',
                                        is_core: true,
                                        key_column: 0)
        meta_entity.add_meta_attribute(name: 'key_term', index: 0)
        expect(meta_entity.key).to be :key_term
      end

      it 'returns the key for extensions' do
        meta_entity = archive.add_meta_entity(term: 'example.org/item',
                                        is_core: false,
                                        key_column: 1)
        meta_entity.add_meta_attribute(name: 'foreign_key', index: 1)
        expect(meta_entity.key).to be :foreign_key
      end

      it 'auto generates a name for a column from the term' do
        meta_entity = archive.add_meta_entity(term: 'example.org/item')
        a = meta_entity.add_meta_attribute(term: 'example.org/termA')
        expect(a.name).to eq 'term_a'
      end

      it 'rasies an error if there is neither name nor term' do
        meta_entity = archive.add_meta_entity(term: 'example.org/item')
        expect { meta_entity.add_meta_attribute(index: 0) }
          .to raise_error Sequel::NotNullConstraintViolation
      end
    end

    it 'gets the names of the content files' do
      meta_entity = archive.add_meta_entity(term: 'example.org/item')
      meta_entity.add_content_file(name: 'file_a.csv')
      meta_entity.add_content_file(name: 'file_b.csv')
      file_names = meta_entity.content_files.map(&:name)
      expect(file_names).to include('file_a.csv', 'file_b.csv')
    end
  end
end
