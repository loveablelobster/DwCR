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
    it 'returns a list of alt_names as content headers, sorted by index' do
      meta_entity = MetaEntity.create(term: 'example.org/item')
      meta_entity.add_meta_attribute(name: 'term_b', index: 2)
      meta_entity.add_meta_attribute(name: 'term_a', index: 1)
      content_file = meta_entity.add_content_file(name: 'file', path: 'home')
      expect(content_file.content_headers).to contain_exactly(:term_a, :term_b)
    end

    # example for load

    # example for unload!

    # example for error when extension is loaded before core

#     it 'skips blank columns in a csv' do
#       meta_entity = MetaEntity.create(term: 'example.org/item')
#       meta_entity.add_meta_attribute(name: 'term_a', index: 0, type: 'string')
#       meta_entity.add_meta_attribute(name: 'term_b', index: 1, type: nil)
#       meta_entity.add_meta_attribute(name: 'term_c', index: 2, type: 'string')
#       meta_entity.add_meta_attribute(name: 'term_d', index: 3, type: 'string')
#       meta_entity.add_meta_attribute(name: 'term_e', index: 4, type: nil)
#       meta_entity.add_meta_attribute(name: 'term_f', index: 5, type: 'string')
#       meta_entity.add_meta_attribute(name: 'term_g', index: 6, type: 'string')
#       meta_entity.add_meta_attribute(name: 'term_h', index: 7, type: 'string')
#       meta_entity.add_meta_attribute(name: 'term_i', index: 8, type: nil)
#       meta_entity.add_meta_attribute(name: 'term_j', index: 9, type: 'string')
#
#       content_file = meta_entity.add_content_file(name: 'file', path: 'home')
#       row = [
#         'value a',
#         'skip b',
#         'value c',
#         'value d',
#         'skip e',
#         'value f',
#         'value g',
#         'value h',
#         'skip i',
#         'value j'
#         ]
#       expect(content_file.values_for(row)).to eq({term_a: 'value a',
#                                                  term_c: 'value c',
#                                                  term_d: 'value d',
#                                                  term_f: 'value f',
#                                                  term_g: 'value g',
#                                                  term_h: 'value h',
#                                                  term_j: 'value j'
#                                                  })
#     end
  end
end
