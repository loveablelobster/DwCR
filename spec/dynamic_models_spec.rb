# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

#     config.around(:each) do |example|
#       DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
#     end
  end

  RSpec.describe 'DynamicModels' do
    before :context do
      DB.create_table :core_items do
        primary_key :id
        foreign_key :meta_entity_id
      end

      DB.create_table :extension_items do
        primary_key :id
        foreign_key :meta_entity_id
        foreign_key :core_item_id
      end
    end

    let :archive do
      c = double('MetaEntity')
      allow(c).to receive_messages(
        class_name: 'CoreItem',
        model_associations: [
          [:many_to_one, :meta_entity, { class: 'MetaEntity' }],
          [:one_to_many, :extension_items, { class: 'ExtensionItem' }]
        ],
        table_name: :core_items
      )
      e = double('MetaEntity')
      allow(e).to receive_messages(
        class_name: 'ExtensionItem',
        model_associations: [
          [:many_to_one, :meta_entity, { class: 'MetaEntity' }],
          [:many_to_one, :core_items, { class: 'CoreItem' }]
        ],
        table_name: :extension_items
      )
      a = double('MetaArchive')
      allow(a).to receive(:meta_entities).and_return [c, e]
      a
    end

    context 'creates a model class that' do
      it 'has Sequel::Model in its inhertiance chain' do
      	m = DwCR.create_model(archive.meta_entities.first)
      	expect(m.superclass.superclass).to be Sequel::Model
      end

#       it 'references the MetaEntity instance it was created from' do
#         m = DwCR.create_model(archive.meta_entities.first)
#         expect(m.meta_entity).to be_a_kind_of MetaEntity
#       end

      it 'is associated with MetaEntity' do
        m = DwCR.create_model(archive.meta_entities.first)
        expect(m.associations).to include :meta_entity
      end

      it 'is associated with ExtensionItem' do
        m = DwCR.create_model(archive.meta_entities.first)
        expect(m.associations).to include :extension_items
      end
    end

    after :example do
    	DwCR.send(:remove_const, 'CoreItem')
    end

    after :context do
    	DB.drop_table(:core_items, :extension_items)
    end
  end
end
