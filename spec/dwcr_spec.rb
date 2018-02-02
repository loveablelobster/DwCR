# frozen_string_literal: true

require_relative 'support/models_shared_context'

RSpec.describe 'DwCR' do
  include_context 'Models helpers'

  def create_and_load_schema
    DwCR.create_schema archive
    DwCR.load_models archive
  end

  let :archive do
    path = File.path('spec/support/example_archive')
    archive = DwCR::MetaArchive.create(path: path)
    archive.load_nodes_from(XMLParsable.load_meta(File.join(path, 'meta.xml')))
  end

  after do
    DB.drop_table? :extension_items
    DB.drop_table? :core_items
  end

  context 'when updating the (meta)schema' do
    it 'updates the column type if the type: true option is passed' do
      DwCR::Metaschema.update archive, type: true
      expect(archive.core.meta_attributes.map(&:to_table_column))
        .to include a_collection_including(:date_column, :date)
    end

    it 'updates the column type if the type: true option is passed' do
      DwCR::Metaschema.update archive, length: true
      expect(archive.core
                    .meta_attributes_dataset
                    .first(name: 'text_column')
                    .length).to be 25
    end
  end

  context 'when creating the DwCA schema' do

    context 'when creating a DwCA schema table' do
      let :schema_entity do
        fk = { name: 'dwca_foreign_key_field', index: 0 }
        a1 = { name: 'col1', index: 1 }
        a2 = { name: 'col2', index: 2, default: 'default' }
        e = entity('example.org/SchemaSpecItem',
                   key_column: 0,
                   with_attributes: [fk, a1, a2])
        archive.core.add_extension(e)
        e
      end

      before { DwCR.create_schema_table(schema_entity) }

      it 'creates the table' do
        expect(DB.table_exists?(:schema_spec_items)).to be_truthy
      end

      it 'inserts a foreign key for meta_entities' do
        expect(DB.schema(:schema_spec_items))
          .to include a_collection_including(:meta_entity_id,
                                             a_hash_including(type: :integer))
      end

      it 'skips the foreign key field declared in extensions' do
      	expect(DB.schema(:schema_spec_items))
      	  .not_to include a_collection_including(:dwca_foreign_key_field)
      end

      it 'adds the SQL foreign key to extension tables' do
        expect(DB.schema(:schema_spec_items))
          .to include a_collection_including(:core_item_id,
                                             a_hash_including(type: :integer))
      end

      it 'adds any regular fields' do
      	expect(DB.schema(:schema_spec_items))
      	  .to include a_collection_including(:col1),
      	              a_collection_including(:col2,
      	                                     a_hash_including(default: '\'default\''))
      end

      context 'when adding a foreign key' do
        # DwCR.add_foreign_key(table, entity)
      end
    end





    it 'creates the table for the DwCA core' do
    	DwCR.create_schema archive
    	expect(DB.table_exists?(:core_items)).to be_truthy
    end

    it 'creates the table for DwCA extensions' do
    	DwCR.create_schema archive
    	expect(DB.table_exists?(:extension_items)).to be_truthy
    end

    it 'updates the schema before creating tables if options are passed' do
      DwCR.create_schema archive, type: true
      expect(DB.schema(:core_items))
        .to include a_collection_including(:date_column,
                                           a_hash_including(db_type: 'date'))
    end
  end

  context 'when loading the models for the schema' do
    it 'creates a model for the core' do
      create_and_load_schema
      expect(DwCR::CoreItem).to be_a Class
    end

    it 'creates a model for each extension' do
      create_and_load_schema
      expect(DwCR::ExtensionItem).to be_a Class
    end

    after do
      DwCR::CoreItem.finalize
      DwCR::ExtensionItem.finalize
    end
  end

  context 'when loading the contents' do
    it 'loads all core and extension files' do
      create_and_load_schema
      DwCR.load_contents_for archive
      core_item1 = DwCR::CoreItem.first
      expect(core_item1.extension_items.map(&:values))
        .to include a_hash_including(core_item_number: core_item1.item_number)
    end

    after do
      DwCR::CoreItem.finalize
      DwCR::ExtensionItem.finalize
    end
  end
end
