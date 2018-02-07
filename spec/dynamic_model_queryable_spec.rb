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

  it 'returns a record in json format' do
    rec = DwCR::CoreItem.first(item_number: 1)

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
#     p JSON.generate hsh
#     p rec
    expect(rec.to_json).to eq hsh
  end

  after :context do
    DwCR::CoreItem.finalize
    DwCR::ExtensionItem.finalize
  end
end
