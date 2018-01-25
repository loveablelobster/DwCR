# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
    end
  end

  RSpec.describe 'MetaArchive' do
    let(:archive) { MetaArchive.create(path: Dir.pwd) }

    def xml
      doc = <<~HEREDOC
        <archive>
          <core rowType="example.org/Core">
            <files><location>core.csv</location></files>
            <id index="0"/><field index="0" term="example.org/Key"/>
          </core>
          <extension rowType="example.org/Extension">
            <files><location>extension.csv</location></files>
            <coreid index="0"/><field index="1" term="example.org/Term"/>
          </extension>
        </archive>
      HEREDOC
      Nokogiri::XML(doc)
    end

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
        archive.load_entities_from xml
        expect(archive.core
                      .extensions).to contain_exactly(*archive.extensions)
      end

      it '_extensions_ reference the _core_' do
        archive.load_entities_from xml
        expect(archive.extensions.first.core).to eq archive.core
      end

      it 'adds attributes declared in _field_ nodes' do
        archive.load_entities_from xml
        expect(archive.core.meta_attributes.map(&:values))
          .to include a_hash_including(term: 'example.org/Key', index: 0)
      end

      it 'adds files declared in the _files_ node' do
        archive.load_entities_from xml
        expect(archive.core.content_files.map(&:values))
          .to include a_hash_including(name: 'core.csv')
      end
    end
  end
end
