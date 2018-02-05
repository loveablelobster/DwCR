# frozen_string_literal: true

#
module DwCR
  RSpec.describe 'DynamicModels' do
    let :archive do
      a = Metaschema::Archive.create(name: 'content_file_spec')
      a.core = a.add_entity(term: 'example.org/coreItem', key_column: 0)
      a.core.save
      a.core.add_attribute(name: 'term_a', index: 0)
      e = a.add_extension(term: 'example.org/extensionItem', key_column: 0)
      e.add_attribute(name: 'coreid', index: 0)
      a.entities.each { |entity| DwCR.create_schema_table(entity) }
      a
    end

    context 'when created, a model class' do
      it 'has Sequel::Model in its inhertiance chain' do
        m = DwCR.create_model(archive.core)
        expect(m.superclass.superclass).to be Sequel::Model
        m.finalize
      end

      it 'references the Entity instance it was created from' do
        m = DwCR.create_model(archive.core)
        expect(m.entity).to be archive.core
        m.finalize
      end

      it 'is associated with Entity' do
        m = DwCR.create_model(archive.core)
        expect(m.associations).to include :entity
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
