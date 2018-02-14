# frozen_string_literal: true

require_relative '../lib/dwcr/dynamic_model_queryable'

RSpec.describe DynamicModelQueryable do
  before :context do
    path = File.path('spec/support/example_archive')
    archive = DwCR::Metaschema::Archive.create(path: path)
    archive.load_nodes_from(DwCR::Metaschema::XMLParsable.load_meta(File.join(path, 'meta.xml')))
    DwCR.create_schema archive
    DwCR.load_models archive
    DwCR.load_contents_for archive
  end

  let(:core_row) { DwCR::CoreItem.first(item_number: 1) }

  let(:extension_row) { DwCR::ExtensionItem.first(identifier: 'extension-2-4') }

  context 'when returning extension rows' do
    it 'returns nil if the record is an extension itself' do
      expect(extension_row.extension_rows).to be_nil
    end

    it 'returns the rows for the extension given in the argument' do
      expect(core_row.extension_rows)
        .to match_array core_row.extension_items
    end
  end

  context 'when returning the core row' do
    it 'returns nil if the record is the core itself' do
      expect(core_row.core_row).to be_nil
    end

    it 'returns the rows for the extension given in the argument' do
      expect(extension_row.core_row)
        .to be extension_row.core_item
    end
  end

  context 'when returning the row values, the returned hash' do
    it 'does not contain the primary key' do
      expect(core_row.row_values).not_to include :id
    end

    it 'does not contain the foreign key for the entity' do
      expect(core_row.row_values).not_to include :entity_id
    end

    it 'does not contain the foreign key for the core'\
       ' if the row is an extension' do
      expect(extension_row.row_values).not_to include :core_item_id
    end
  end

  context 'when returning a hash with given kind of key' do
    it 'returns the normal row_values hash if the _keys_ argument is +name+' do
      expect(core_row.to_hash_with(:name))
        .to include empty_column: nil,
                    mixed_column: 'Text',
                    numeric_column: 1,
                    empty_column!: 'default value'
    end

    it 'returns the hash with basrterms'\
       ' (where ambiguous baseterms will be the full terms)' do
      expect(core_row.to_hash_with(:baseterm))
        .to include 'example.org/terms/emptyColumn' => nil,
                    'mixedColumn' => 'Text',
                    'numericColumn' => 1,
                    'example.org/elements/emptyColumn' => 'default value'
    end

    it 'returns the hash with terms' do
      expect(core_row.to_hash_with(:term))
        .to include 'example.org/terms/emptyColumn' => nil,
                    'example.org/terms/mixedColumn' => 'Text',
                    'example.org/terms/numericColumn' => 1,
                    'example.org/elements/emptyColumn' => 'default value'
    end
  end

  context 'when returning full records' do
  	it 'returns a core row as hash with keys as specified'\
  	   ' including all extension rows' do
  	  xtnrows = core_row.extension_items.map { |ei| ei.to_hash_with(:term) }
      expect(core_row.to_record)
        .to include 'example.org/terms/coreID' => "core-1",
                    'example.org/terms/ExtensionItem' => match_array(xtnrows)
  	end

  	it 'returns an extension row as hash with keys as specified'\
  	   ' including the core row the extension row belongs to' do
  	  crow = extension_row.core_item.to_hash_with(:term)
      expect(extension_row.to_record)
        .to include 'example.org/terms/identifier' => "extension-2-4",
                    'example.org/terms/coreItemNumber' => 1,
                    'http://example.org/dwcr/terms/CoreItem' => crow
  	end
  end

  context 'when returning JSON' do
    it 'returns a core and all related extensions as JSON ' do
      expect(core_row.to_json)
        .to eq '{"example.org/terms/coreID":"core-1",'\
               '"example.org/terms/itemNumber":1,'\
               '"example.org/terms/emptyColumn":null,'\
               '"example.org/terms/textColumn":"Text with 18 chars",'\
               '"example.org/terms/mixedColumn":"Text",'\
               '"example.org/terms/numericColumn":1,'\
               '"example.org/terms/dateColumn":"2017-06-12",'\
               '"example.org/elements/emptyColumn":"default value",'\
               '"example.org/terms/ExtensionItem":['\
               '{"example.org/terms/identifier":"extension-2-4",'\
               '"example.org/terms/coreItemNumber":1}'\
               ',{"example.org/terms/identifier":"extension-2-5",'\
               '"example.org/terms/coreItemNumber":1},'\
               '{"example.org/terms/identifier":"extension-2-6",'\
               '"example.org/terms/coreItemNumber":1}]}'
    end

    it 'returns an extensions and the core it belongs to as JSON ' do
      expect(extension_row.to_json)
        .to eq '{"example.org/terms/identifier":"extension-2-4",'\
               '"example.org/terms/coreItemNumber":1,'\
               '"http://example.org/dwcr/terms/CoreItem":'\
               '{"example.org/terms/coreID":"core-1",'\
               '"example.org/terms/itemNumber":1,'\
               '"example.org/terms/emptyColumn":null,'\
               '"example.org/terms/textColumn":"Text with 18 chars",'\
               '"example.org/terms/mixedColumn":"Text",'\
               '"example.org/terms/numericColumn":1,'\
               '"example.org/terms/dateColumn":"2017-06-12",'\
               '"example.org/elements/emptyColumn":"default value"}}'
    end
  end

  after :context do
    DwCR::CoreItem.finalize
    DwCR::ExtensionItem.finalize
  end
end
