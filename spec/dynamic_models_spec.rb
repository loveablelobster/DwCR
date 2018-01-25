# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around(:each) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'DynamicModels' do
    before :example do
      @archive = MetaArchive.create(name: 'content_file_spec')
      @archive.core = @archive.add_meta_entity(term: 'example.org/coreItem',
                                               key_column: 0)
      @archive.core.save
      @archive.core.add_meta_attribute(name: 'term_a', index: 0)
      extension = @archive.add_extension(term: 'example.org/extensionItem',
                                         key_column: 0)
      extension.add_meta_attribute(name: 'coreid', index: 0)
      @archive.meta_entities.each { |entity| DwCR.create_schema_table(entity) }
    end

    context 'creates a model class that' do
      it 'has Sequel::Model in its inhertiance chain' do
      	@m = DwCR.create_model(@archive.core)
      	expect(@m.superclass.superclass).to be Sequel::Model
      end

      it 'references the MetaEntity instance it was created from' do
        @m = DwCR.create_model(@archive.core)
        expect(@m.meta_entity).to be @archive.core
      end

      it 'is associated with MetaEntity' do
        @m = DwCR.create_model(@archive.core)
        expect(@m.associations).to include :meta_entity
      end

      it 'is associated with ExtensionItem' do
        @m = DwCR.create_model(@archive.core)
        expect(@m.associations).to include :extension_items
      end
    end

    after :example do
      @m.finalize
    end
  end
end
