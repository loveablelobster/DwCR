# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
    end
  end

  RSpec.describe 'ContentFile' do
    it 'returns the full file name including the path' do
      f = ContentFile.create(name: 'table.csv', path: File.path('/dev/null'))
      expect(f.file_name).to eq(File.path('/dev/null/table.csv'))
    end

    context 'when returning column names as an array of symbols for names' do
      let(:h) do
        e = MetaEntity.create(term: 'example.org/item')
        e.add_meta_attribute(name: 'term_a', index: 0, type: 'string')
        e.add_meta_attribute(name: 'term_b', index: 1, type: nil)
        e.add_meta_attribute(name: 'term_c', index: nil, type: 'string')
        e.add_meta_attribute(name: 'term_d', index: 2, type: 'string')
        e.add_meta_attribute(name: 'term_e', index: nil, type: nil)
        f = e.add_content_file(name: 'table.csv')
        f.content_headers
      end

      it 'includes attributes that have index and type' do
        expect(h).to include(:term_a, :term_d)
      end

      it 'does not include attributes that do not have an index' do
        expect(h).not_to include :term_c
      end

      it 'does not include attributes that do not have a type' do
        expect(h).not_to include :term_b
      end

      it 'does not include attributes that have neither index nor type' do
        expect(h).not_to include :term_e
      end
    end

    context 'when loading and unloading files' do
      before :context do
        @file = File.join(Dir.pwd, 'table.csv')
        CSV.open(@file, 'wb') do |csv|
          csv << %w[a1 b1 c1]
          csv << %w[a2 b2 c2]
        end
      end

      let :archive do
        a = MetaArchive.create(name: 'content_file_spec')
        a.core = a.add_meta_entity(term: 'example.org/coreItem', key_column: 0)
        a.core.save
        a.core.add_meta_attribute(name: 'term_a', index: 0)
        a.core.add_meta_attribute(name: 'term_b', index: 1)
        a.core.add_meta_attribute(name: 'term_c', index: 2)
        e = a.add_extension(term: 'example.org/extensionItem', key_column: 0)
        e.add_meta_attribute(name: 'term_a', index: 0)
        e.add_meta_attribute(name: 'term_b', index: 1)
        e.add_meta_attribute(name: 'term_c', index: 2)
        a.core.add_content_file(name: 'table.csv', path: Dir.pwd)
        e.add_content_file(name: 'table.csv', path: Dir.pwd)
        a.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
        @models = DwCR.load_models(a)
        a
      end

      it 'will not load if the file is already loaded' do
        archive.core.content_files.first.load
        expect(archive.core.content_files.first.load).not_to be_truthy
      end

      it 'will raise an error if the parent row has not been loaded' do
        expect { archive.extensions.first.content_files.first.load }
          .to raise_error(RuntimeError,
                          'core needs to be loaded before extension files')
      end

      it 'set the is_loaded flag to true after successful loading' do
        archive.core.content_files.first.load
        expect(archive.core.content_files.first.is_loaded).to be_truthy
      end

      it 'loads the rows for the core' do
        archive.core.content_files.first.load
        expect(DwCR::CoreItem.all.map(&:values))
          .to contain_exactly(a_hash_including(term_a: 'a1', term_b: 'b1'),
                              a_hash_including(term_a: 'a2', term_c: 'c2'))
      end

      it 'loads the rows for an extension' do
        archive.core.content_files.first.load
        archive.extensions.first.content_files.first.load
        expect(DwCR::ExtensionItem.all.map(&:values))
          .to contain_exactly(a_hash_including(term_b: 'b1', term_c: 'c1'),
                              a_hash_including(term_b: 'b2', term_c: 'c2'))
      end

      it 'core rows reference to related extension rows' do
        archive.core.content_files.first.load
        archive.extensions.first.content_files.first.load
        expect(DwCR::CoreItem.first.extension_items.map(&:values))
          .to contain_exactly a_hash_including(term_b: 'b1', term_c: 'c1')
      end

      it 'will return nil if the rows to be removed have not been loaded' do
        expect(archive.core.content_files.first.unload!).to be_falsey
      end

      it 'deletes the rows' do
        archive.core.content_files.first.load
        archive.core.content_files.first.unload!
        expect(DwCR::CoreItem.all).to match_array []
      end

      it 'set the is_loaded flag to false after successful deletion' do
        archive.core.content_files.first.load
        archive.core.content_files.first.unload!
        expect(archive.core.content_files.first.is_loaded).to be_falsey
      end

      after do
        @models.each(&:finalize)
      end

      after :context do
        File.delete @file
      end
    end
  end
end
