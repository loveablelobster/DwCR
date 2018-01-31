# frozen_string_literal: true

require_relative 'support/models_shared_context'

#
module DwCR
  RSpec.describe 'ContentFile' do
    include_context 'Models helpers'

    def add_attributes_to(entity, *attrs)
      attrs
        .each_with_index { |a, i| entity.add_meta_attribute(name: a, index: i) }
    end

    def add_core_to(archive)
      archive.core = archive.add_meta_entity(term: 'example.org/coreItem',
                                             key_column: 0)
      archive.core.save
      add_attributes_to(archive.core, 'term_a', 'term_b', 'term_c')
      archive.core.add_content_file(name: 'table.csv', path: Dir.pwd)
    end

    def add_extension_to(archive)
      extension = archive.add_extension(term: 'example.org/extensionItem',
                                        key_column: 0)
      add_attributes_to(extension, 'term_a', 'term_b', 'term_c')
      extension.add_content_file(name: 'table.csv', path: Dir.pwd)
    end

    it 'returns the full file name including the path' do
      f = ContentFile.create(name: 'table.csv', path: File.path('/dev/null'))
      expect(f.file_name).to eq(File.path('/dev/null/table.csv'))
    end

    context 'when returning column names as an array of symbols for names' do
      let(:h) do
        e = archive.add_meta_entity(term: 'example.org/item')
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
        CSV.open(File.join(Dir.pwd, 'table.csv'), 'wb') do |csv|
          csv << %w[a1 b1 c1]
          csv << %w[a2 b2 c2]
        end
      end

      let :archive do
        MetaArchive.create(name: 'content_file_spec')
      end

      before do
        add_core_to archive
        add_extension_to archive
        archive.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
        DwCR.load_models(archive)
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
        CoreItem.finalize
        ExtensionItem.finalize
      end

      after :context do
        File.delete File.join(Dir.pwd, 'table.csv')
      end
    end
  end
end
