# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around(:each) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'ContentFile' do
    it 'returns the full file name including the path' do
      f = ContentFile.create(name: 'table.csv', path: File.path('/dev/null'))
      expect(f.file_name).to eq(File.path('/dev/null/table.csv'))
    end

    context 'returns column names as an array of symbols for names' do
      let(:h) do
        e = MetaEntity.create(term: 'example.org/item')
        e.add_meta_attribute(name: 'term_a', index: 0, type: 'string')
        e.add_meta_attribute(name: 'term_b', index: 1, type: nil)
        e.add_meta_attribute(name: 'term_c', index: nil, type: 'string')
        e.add_meta_attribute(name: 'term_d', index: 2, type: 'string')
        e.add_meta_attribute(name: 'term_e', index: nil, type: nil)
        f = e.add_content_file(name: 'table.csv')
        f.content_headers
      end

      it 'including attributes that have index and type' do
        expect(h).to include(:term_a, :term_d)
      end

      it 'not including attributes that do not have an index' do
      	expect(h).not_to include :term_c
      end

      it 'not including attributes that do not have a type' do
      	expect(h).not_to include :term_b
      end

      it 'not including attributes that have neither index nor type' do
      	expect(h).not_to include :term_e
      end
    end

    context 'loads' do

    end

    context 'unloads' do

    end
  end
end
