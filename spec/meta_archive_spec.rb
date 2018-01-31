# frozen_string_literal: true

require_relative 'support/models_shared_context'

#
module DwCR
  RSpec.describe 'MetaArchive' do
    include_context 'Models helpers'

    context 'when adding core and extensions' do
      it 'ensures that is_core is true for the core' do
        archive.core = archive.add_meta_entity(term: 'example.org/core')
        expect(archive.core.is_core).to be_truthy
      end

      it 'ensures that is_core is false for extensions' do
        archive.core = archive.add_meta_entity(term: 'example.org/core')
        extension = archive.add_extension(term: 'example.org/extension')
        expect(extension.is_core).to be_falsey
      end

      it 'ensures that extensions added reference the core' do
        archive.core = archive.add_meta_entity(term: 'example.org/core')
        extension = archive.add_extension(term: 'example.org/extension')
        expect(extension.core).to be archive.core
      end

      it 'raises and error if an extension is added when there is no core' do
        expect { archive.add_extension(term: 'example.org/extension') }
          .to raise_error RuntimeError, 'adding an extension without a core'
      end
    end

    context 'when creating meta_entities from xml' do
      it '_core_ references any _extensions_' do
        archive.load_nodes_from meta_xml
        expect(archive.core
                      .extensions).to contain_exactly(*archive.extensions)
      end

      it '_extensions_ reference the _core_' do
        archive.load_nodes_from meta_xml
        expect(archive.extensions.first.core).to eq archive.core
      end

      it 'adds attributes declared in _field_ nodes' do
        archive.load_nodes_from meta_xml
        expect(archive.core.meta_attributes.map(&:values))
          .to include a_hash_including(term: 'example.org/terms/coreID',
                                       index: 0)
      end

      it 'adds files declared in the _files_ node' do
        archive.load_nodes_from meta_xml
        expect(archive.core.content_files.map(&:values))
          .to include a_hash_including(name: 'core_file.csv')
      end
    end
  end
end
