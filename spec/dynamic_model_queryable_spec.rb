 # frozen_string_literal: true

RSpec.describe 'Dynamic Models mixins' do
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
    	expect(DwCR::ExtensionItem.first.extension_rows).to be_nil
    end

    it 'returns the rows for the extension given in the argument' do
      expect(core_row.extension_rows)
        .to match_array core_row.extension_items
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

  it 'returns a record' do

    hsh = {
      'example.org/terms/coreID' => "core-1",
      'example.org/terms/itemNumber' => 1,
      'example.org/terms/emptyColumn' => nil,
      'example.org/terms/textColumn' => "Text with 18 chars",
      'example.org/terms/mixedColumn' => "Text",
      'example.org/terms/numericColumn' => 1,
      'example.org/terms/dateColumn' => "2017-06-12",
      'example.org/elements/emptyColumn' => "default value",
      'example.org/terms/ExtensionItem' => [
                                             { 'example.org/terms/identifier' => "extension-2-4", 'example.org/terms/coreItemNumber' => 1 },
                                             { 'example.org/terms/identifier'=>"extension-2-5", 'example.org/terms/coreItemNumber' => 1 },
                                             { 'example.org/terms/identifier'=>"extension-2-6", 'example.org/terms/coreItemNumber' => 1 }
                                           ]
    }
    expect(core_row.to_record).to eq hsh
  end

  after :context do
    DwCR::CoreItem.finalize
    DwCR::ExtensionItem.finalize
  end
end
