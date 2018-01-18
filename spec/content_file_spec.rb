# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around(:each) do |example|
      Sequel::Model.db
                    .transaction(rollback: :always,
                                 auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'ContentFile' do
    it 'returns a list of alt_names as content headers, sorted by index' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      meta_entity.add_meta_attribute(name: 'term_b', index: 2)
      meta_entity.add_meta_attribute(name: 'term_a', index: 1)
      content_file = meta_entity.add_content_file(name: 'file', path: 'home')
      expect(content_file.content_headers).to contain_exactly(:term_a, :term_b)
    end
  end
end
