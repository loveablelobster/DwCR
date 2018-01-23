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

    context 'inserts and deletes rows' do
      before(:context) do
        @file = File.join(Dir.pwd, 'table.csv')
        CSV.open(@file, "wb") do |csv|
          csv << ["a1", "b1", "c1"]
          csv << ["a2", "b2", "c2"]
        end
      end

      let(:f) do
        s = Schema.new
        s.archive.core = s.archive.add_meta_entity(term: 'example.org/core')
        e = s.archive.core.add_extension(term: 'example.org/extension')
        e.add_meta_attribute(name: 'term_a', index: 0)
        e.add_meta_attribute(name: 'term_b', index: 1)
        e.add_meta_attribute(name: 'term_c', index: 2)
        s.create_schema
        e.add_content_file(name: 'table.csv', path: Dir.pwd)
      end

      context 'loads' do
        it 'will not load if the file is already loaded' do

        end

        it 'will raise an error if the parent row has not been loaded' do

        end

        it 'loads the rows' do

        end

        it 'set the is_loaded flag to true after successful loading' do

        end
      end

      context 'unloads' do
        it 'will return nil if the rows to be removed have not been loaded' do

        end

        it 'deletes the rows' do

        end

         it 'set the is_loaded flag to false after successful deletion' do

        end
      end

      after(:context) do
        File.delete @file
      end
    end
  end
end
