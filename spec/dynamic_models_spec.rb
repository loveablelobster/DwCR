# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
    end
  end

  RSpec.describe 'DynamicModels' do
    let :archive do
      a = MetaArchive.create(name: 'content_file_spec')
      a.core = a.add_meta_entity(term: 'example.org/coreItem', key_column: 0)
      a.core.save
      a.core.add_meta_attribute(name: 'term_a', index: 0)
      e = a.add_extension(term: 'example.org/extensionItem', key_column: 0)
      e.add_meta_attribute(name: 'coreid', index: 0)
      a.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
      a
    end

    context 'when created, a model class' do
      it 'has Sequel::Model in its inhertiance chain' do
        m = DwCR.create_model(archive.core)
        expect(m.superclass.superclass).to be Sequel::Model
        m.finalize
      end

      it 'references the MetaEntity instance it was created from' do
        m = DwCR.create_model(archive.core)
        expect(m.meta_entity).to be archive.core
        m.finalize
      end

      it 'is associated with MetaEntity' do
        m = DwCR.create_model(archive.core)
        expect(m.associations).to include :meta_entity
        m.finalize
      end

      it 'is associated with any extensions if it is the core' do
        m = DwCR.create_model(archive.core)
        expect(m.associations).to include :extension_items
        m.finalize
      end

      it 'is associated with the core if it is an extension' do
        m = DwCR.create_model(archive.extensions.first)
        expect(m.associations).to include :core_item
        m.finalize
      end
    end
  end
end
