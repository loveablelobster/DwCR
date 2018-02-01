# frozen_string_literal: true

require_relative '../lib/db/schema'

RSpec.describe DwCR, '#module methods' do
  context 'when creating the metaschema' do
    it 'creates the meta_archives table' do
      expect(DB.table_exists?(:meta_archives)).to be_truthy
    end

    context 'when created the meta_archives table' do
      let(:columns) { DB.schema(:meta_archives) }

      it 'has a core_id foreign key column (integer)' do
        expect(columns)
          .to include a_collection_including(:core_id,
                                             a_hash_including(type: :integer))
        # FIXME: test for index: true
      end

      it 'has name column (string)' do
        expect(columns)
          .to include a_collection_including(:name,
                                             a_hash_including(type: :string))
      end

      it 'has a path column (string)' do
        expect(columns)
          .to include a_collection_including(:path,
                                             a_hash_including(type: :string))
      end

      it 'has a xmlns column (string, default:'\
         ' \'http://rs.tdwg.org/dwc/text/\')' do
        d = '\'http://rs.tdwg.org/dwc/text/\''
        expect(columns)
          .to include a_collection_including(:xmlns,
                                             a_hash_including(type: :string,
                                                              default: d))
      end

      it 'has a xmlns__xs column (string, default:'\
         ' \'http://www.w3.org/2001/XMLSchema\')' do
        d = '\'http://www.w3.org/2001/XMLSchema\''
        expect(columns)
          .to include a_collection_including(:xmlns__xs,
                                             a_hash_including(type: :string,
                                                              default: d))
      end

      it 'has a xmlns__xsi column (string, default:'\
         ' \'http://www.w3.org/2001/XMLSchema-instance\')' do
        d = '\'http://www.w3.org/2001/XMLSchema-instance\''
        expect(columns)
          .to include a_collection_including(:xmlns__xsi,
                                             a_hash_including(type: :string,
                                                              default: d))
      end

      it 'has a xsi__schema_location column (string, default:'\
         ' \'http://rs.tdwg.org/dwc/text/'\
         ' http://rs.tdwg.org/dwc/text/tdwg_dwc_text.xsd\')' do
        d = '\'http://rs.tdwg.org/dwc/text/'\
            ' http://rs.tdwg.org/dwc/text/tdwg_dwc_text.xsd\''
        expect(columns)
          .to include a_collection_including(:xsi__schema_location,
                                             a_hash_including(type: :string,
                                                              default: d))
      end
    end

    it 'creates the meta_attributes table' do
      expect(DB.table_exists?(:meta_attributes)).to be_truthy
    end

    context 'when creating the meta_attributes table' do
      let(:columns) { DB.schema(:meta_attributes) }

      it 'has a meta_entity_id foreign key column (integer)' do
        expect(columns)
          .to include a_collection_including(:meta_entity_id,
                                             a_hash_including(type: :integer))
        # FIXME: test for index: true
      end

      it 'has a type column (string, default: \'string\')' do
        d = '\'string\''
        expect(columns)
          .to include a_collection_including(:type,
                                             a_hash_including(type: :string,
                                                              default: d))
      end

      it 'has a name column (string, allow null: false)' do
        a_n = false
        expect(columns)
          .to include a_collection_including(:name,
                                             a_hash_including(type: :string,
                                                              allow_null: a_n))
        # FIXME: test for index: true
      end

      it 'has a term column (string)' do
        expect(columns)
          .to include a_collection_including(:term,
                                             a_hash_including(type: :string))
      end

      it 'has a default column (string)' do
        expect(columns)
          .to include a_collection_including(:default,
                                             a_hash_including(type: :string))
      end

      it 'has an index column (integer)' do
        expect(columns)
          .to include a_collection_including(:index,
                                             a_hash_including(type: :integer))
      end

      it 'has a max_content_length column (integer)' do
        expect(columns)
          .to include a_collection_including(:max_content_length,
                                             a_hash_including(type: :integer))
      end
    end

    it 'creates the meta_entities table' do
      expect(DB.table_exists?(:meta_entities)).to be_truthy
    end

    context 'when creating the meta_entities table' do
      let(:columns) { DB.schema(:meta_entities) }

      it 'has a meta_archive_id foreign key column (integer)' do
        expect(columns)
          .to include a_collection_including(:meta_archive_id,
                                             a_hash_including(type: :integer))
        # FIXME: test for index: true
      end

      it 'has a core_id foreign key column (integer)' do
        expect(columns)
          .to include a_collection_including(:core_id,
                                             a_hash_including(type: :integer))
        # FIXME: test for index: true
      end

      it 'has a name column (string, allow null: false)' do
        a_n = false
        expect(columns)
          .to include a_collection_including(:name,
                                             a_hash_including(type: :string,
                                                              allow_null: a_n))
      end

      it 'has a term column (string)' do
        expect(columns)
          .to include a_collection_including(:term,
                                             a_hash_including(type: :string))
      end

      it 'has an is_core column (boolean)' do
        expect(columns)
          .to include a_collection_including(:is_core,
                                             a_hash_including(type: :boolean))
      end

      it 'has a key_column column (integer)' do
        expect(columns)
          .to include a_collection_including(:key_column,
                                             a_hash_including(type: :integer))
      end

      it 'has a fields_enclosed_by column (string, default: \'&quot;\')' do
        d = '\'&quot;\''
        expect(columns)
          .to include a_collection_including(:fields_enclosed_by,
                                             a_hash_including(type: :string,
                                                              default: d))
      end

      it 'has a fields_terminated_by column (srting, default: \',\')' do
        d = '\',\''
        expect(columns)
          .to include a_collection_including(:fields_terminated_by,
                                             a_hash_including(type: :string,
                                                              default: d))
      end

      it 'has a lines_terminated_by column (string, default: \'\r\n\')' do
        d = '\'\r\n\''
        expect(columns)
          .to include a_collection_including(:lines_terminated_by,
                                             a_hash_including(type: :string,
                                                              default: d))
      end
    end

    it 'creates the content_files table' do
      expect(DB.table_exists?(:content_files)).to be_truthy
    end

    context 'when creating the content_files table' do
      let(:columns) { DB.schema(:content_files) }

      it 'has a meta_entity_id foreign key column (integer)' do
        expect(columns)
          .to include a_collection_including(:meta_entity_id,
                                             a_hash_including(type: :integer))
        # FIXME: test for index: true
      end

      it 'has a name column (string, allow null: false)' do
        a_n = false
        expect(columns)
          .to include a_collection_including(:name,
                                             a_hash_including(type: :string,
                                                              allow_null: a_n))
      end

      it 'has a path column (string)' do
        expect(columns)
          .to include a_collection_including(:path,
                                             a_hash_including(type: :string))
      end

      it 'has a is_loaded column (boolean, default: false)' do
        expect(columns)
          .to include a_collection_including(:is_loaded,
                                             a_hash_including(type: :boolean,
                                                              default: '0'))
      end
    end
  end

  context 'when inspecting a table' do
    it 'fetches the schema for the table when passed :schema' do
      expect(DwCR.inspect_table(:content_files, :schema))
        .to include a_collection_including(:name),
                    a_collection_including(:path),
                    a_collection_including(:is_loaded)
    end

    it 'fetches the indexes for the table when passed :indexes' do
      expect(DwCR.inspect_table(:content_files, :indexes))
        .to include :content_files_meta_entity_id_index
    end

    it 'returns false when the table does not exist' do
      expect(DwCR.inspect_table(:not_a_table, :schema)).to be_falsey
    end
  end

  context 'when verifying metaschema integrity' do
    let :content_files_schema do
      yml = File.join(File.expand_path(Dir.pwd), '/lib/db/metaschema_tables.yml')
      Psych.load_file(File.path(yml))[:content_files]
    end

    let :incomplete_schema do
      [
        [:path, :string],
        [:is_loaded, :boolean, { default: false }]
      ]
    end

    it 'it returns true if the metaschema has all tables, columns,'\
       ' and indices defined in config/metaschema_tables.yml' do
      expect(DwCR.metaschema?).to be_truthy
    end

    context 'when inspecting columns' do
      it 'returns true if the table has all columns defined in the yml' do
        expect(DwCR::columns?(:content_files, *content_files_schema)).to be_truthy
      end

      it 'returns false if the table is missing a column defined in the yml' do
        expect(DwCR::columns?(:content_files, *incomplete_schema)).to be_falsey
      end
    end

    context 'when inspecting indexes' do
      it 'returns true if the table has all columns defined in the yml' do
        expect(DwCR::indexes?(:content_files, *content_files_schema)).to be_truthy
      end

      it 'returns false if the table is missing a column defined in the yml' do
        expect(DwCR::columns?(:content_files, *incomplete_schema)).to be_falsey
      end
    end
  end

  context 'when creating a DwCA schema table' do
    # DwCR.create_schema_table(entity)
  end

  context 'when adding a foreign key' do
    # DwCR.add_foreign_key(table, entity)
  end
end
