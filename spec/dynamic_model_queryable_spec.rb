# frozen_string_literal: true

require_relative '../lib/dwcr/dynamic_model_queryable'

RSpec.describe DynamicModelQueryable do
  before :context do
    path = File.path('spec/support/example_archive')
    meta = File.join(path, 'meta.xml')
    archive = DwCR::Metaschema::Archive.create(path: path)
    archive.load_nodes_from(DwCR::Metaschema::XMLParsable.load_meta(meta))
    DwCR.create_schema archive
    DwCR.load_models archive
    DwCR.load_contents_for archive
  end

  def term(element)
    'example.org/terms/' + element
  end

  let(:core_term) { 'http://example.org/dwcr/terms/CoreItem' }
  let(:core_row) { DwCR::CoreItem.first(item_number: 1) }
  let(:extension_term) { 'example.org/terms/ExtensionItem' }
  let(:extension_row) { DwCR::ExtensionItem.first(identifier: 'extension-2-4') }

  describe '.attribute_for' do
    subject(:id_attribute) { DwCR::CoreItem.attribute_for('core_id') }

    it do
      expect(id_attribute).to be_a(DwCR::Metaschema::Attribute)
        .and have_attributes(name: 'core_id', term: 'example.org/terms/coreID')
    end
  end

  describe '.entity' do
    subject(:core_entity) { DwCR::CoreItem.entity }

    it do
      expect(core_entity).to be_a(DwCR::Metaschema::Entity)
        .and have_attributes(term: core_term, is_core: true)
    end
  end

  describe '.template' do
    subject(:template) { DwCR::CoreItem.template }

    let(:core_id) { [core_term, term('coreID')] }
    let(:item_number) { [core_term, term('itemNumber')] }
    let(:empty_column1) { [core_term, term('emptyColumn')] }
    let(:text_column) { [core_term, term('textColumn')] }
    let(:mixed_column) { [core_term, term('mixedColumn')] }
    let(:numeric_column) { [core_term, term('numericColumn')] }
    let(:date_column) { [core_term, term('dateColumn')] }
    let(:empty_column2) { [core_term, 'example.org/elements/emptyColumn'] }
    let(:identifier) { [extension_term, term('identifier')] }
    let(:core_item_number) { [extension_term, term('coreItemNumber')] }

    it do
      expect(template)
        .to contain_exactly core_id, item_number, empty_column1, text_column,
                            mixed_column, numeric_column, date_column,
                            empty_column2,
                            a_collection_containing_exactly(identifier,
                                                            core_item_number)
    end
  end

  describe '#core_row' do
    context 'when self is a core row' do
      subject { core_row.core_row }

      it { is_expected.to be_nil }
    end

    context 'when self is an extension row' do
      subject { extension_row.core_row }

      it do
        is_expected.to be_a(DwCR::CoreItem)
          .and have_attributes core_id: 'core-1', item_number: 1,
                               empty_column: nil,
                               text_column: 'Text with 18 chars',
                               mixed_column: 'Text', numeric_column: 1,
                               date_column: '2017-06-12',
                               empty_column!: 'default value'
      end
    end
  end

  describe '#extension_rows' do
    context 'when self is an extension row' do
      subject { extension_row.extension_rows }

      it { is_expected.to be_nil}
    end

    context 'when self is a core row' do
      subject(:all_extensions) { core_row.extension_rows }

      let(:ext1) do
        an_instance_of(DwCR::ExtensionItem)
          .and have_attributes identifier: 'extension-2-4', core_item_number: 1
      end

      let(:ext2) do
      	an_instance_of(DwCR::ExtensionItem)
          .and have_attributes identifier: 'extension-2-5', core_item_number: 1
      end

      let(:ext3) do
        an_instance_of(DwCR::ExtensionItem)
          .and have_attributes identifier: 'extension-2-6', core_item_number: 1
      end

      it { is_expected.to include ext1, ext2, ext3 }
    end
  end

  describe '#row_values' do
    subject { core_row.row_values }

    it { is_expected.not_to include :id }

    it { is_expected.not_to include :entity_id }

    context 'when self is an extension' do
      subject { extension_row.row_values }

      it { is_expected.not_to include :core_item_id }
    end
  end

  describe '#to_a' do
    subject(:record_array) { core_row.to_a }

    let(:ext1) { a_collection_containing_exactly 'extension-2-4', 1 }
    let(:ext2) { a_collection_containing_exactly 'extension-2-5', 1 }
    let(:ext3) { a_collection_containing_exactly 'extension-2-6', 1 }

    it do
      expect(record_array)
        .to contain_exactly 'core-1', 1, nil, 'Text with 18 chars', 'Text', 1,
                            '2017-06-12', 'default value',
                            a_collection_containing_exactly(ext1, ext2, ext3)
    end
  end

  describe '#to_hash_with' do
    context 'when passed :name' do
      subject(:name_hash) { core_row.to_hash_with(:name) }

      it do
        expect(name_hash)
          .to include empty_column: nil,
                      mixed_column: 'Text',
                      numeric_column: 1,
                      empty_column!: 'default value'
      end
    end

    context 'when passed :baseterm' do
      subject(:baseterm_hash) { core_row.to_hash_with(:baseterm) }

      it do
        expect(baseterm_hash)
          .to include 'example.org/terms/emptyColumn' => nil,
                      'mixedColumn' => 'Text',
                      'numericColumn' => 1,
                      'example.org/elements/emptyColumn' => 'default value'
      end
    end

    context 'when passed :term' do
    	subject(:term_hash) { core_row.to_hash_with(:term) }

      it do
        expect(term_hash)
          .to include 'example.org/terms/emptyColumn' => nil,
                      'example.org/terms/mixedColumn' => 'Text',
                      'example.org/terms/numericColumn' => 1,
                      'example.org/elements/emptyColumn' => 'default value'
      end
    end
  end

  describe '#to_json' do
    context 'when self is the core' do
      subject { core_row.to_json }

      let :json do
      	'{"example.org/terms/coreID":"core-1",'\
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

      it { is_expected.to eq json }
    end

    context 'when self is an extension' do
    	subject {extension_row.to_json}

      let :json do
      	'{"example.org/terms/identifier":"extension-2-4",'\
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

      it { is_expected.to eq json }
    end
  end

  describe '#to_record' do
    context 'when self is core' do
      subject(:core_record) { core_row.to_record }

      let(:xtn_rows) do
      	core_row.extension_items.map { |ei| ei.to_hash_with(:term) }
      end

      it do
        expect(core_record)
          .to include 'example.org/terms/coreID' => "core-1",
                      'example.org/terms/ExtensionItem' => match_array(xtn_rows)
      end
    end

    context 'when self is an extension' do
    	subject(:extension_record) { extension_row.to_record }

      let(:core_hash) do
      	extension_row.core_item.to_hash_with(:term)
      end

      it do
        expect(extension_record)
          .to include 'example.org/terms/identifier' => "extension-2-4",
                      'example.org/terms/coreItemNumber' => 1,
                      'http://example.org/dwcr/terms/CoreItem' => core_hash
      end
    end
  end

  after :context do
    DwCR::CoreItem.finalize
    DwCR::ExtensionItem.finalize
  end
end
