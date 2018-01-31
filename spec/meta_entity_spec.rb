# frozen_string_literal: true

require_relative 'support/models_shared_context'

#
module DwCR
  RSpec.describe 'MetaEntity' do
    include_context 'Models helpers'

    context 'when creating new instances' do
      it 'throws an error if the core is not associated with an archive' do
        m = 'ArgumentError:'\
            ' MetaEntity instances need to belong to a MetaArchive'
        expect { MetaEntity.create(term: 'example.org/DanglingItem') }
          .to raise_error(Sequel::DatabaseError, m)
      end

      it 'inserts name from last component of term (lowercase, underscore)' do
        meta_entity = archive.add_meta_entity(term: 'example.org/AnItem')
        expect(meta_entity.name).to eq 'an_item'
      end
    end

    context 'when adding extensions to the core' do
      it 'throws an error if the core is not associated with an archive' do
        extension = archive.add_meta_entity(term: 'example.org/XtnItem')
        expect { extension.add_extension(term: 'example.org/NestedXtn') }
          .to raise_error(ArgumentError,
                          'extensions must be associated with a core')
      end

      it 'associates the extension with the archive' do
        extension = core.add_extension(term: 'example.org/XtnItem')
        expect(extension.meta_archive).to be archive
      end

      it 'sets the is_core flag to false' do
        extension = core.add_extension(term: 'example.org/XtnItem')
        expect(extension.is_core).to be_falsey
      end
    end

    context 'when adding MetaAttributes (columns)' do
      it 'ensures the column name is unique' do
        attrs = entity(with_attributes: %w[term term]).meta_attributes
        attr1, attr2 = *attrs
        expect(attr1.name == attr2.name).to be_falsey
      end

      it 'suffixs subsequent occurrences of a term with !' do
        attr = entity(with_attributes: %w[term term]).meta_attributes.last
        expect(attr.name).to eq 'term!'
      end

      it 'auto generates a name for a column from the term' do
        attr = { term: 'example.org/termA' }
        expect(entity(with_attributes: [attr]).meta_attributes.last.name)
          .to eq 'term_a'
      end

      it 'rasies an error if there is neither name nor term' do
        expect { entity('example.org/Item').add_meta_attribute(index: 0) }
          .to raise_error Sequel::NotNullConstraintViolation
      end
    end

    it 'returns a class name' do
      expect(entity('example.org/Item').class_name).to eq 'Item'
    end

    it 'gets the names of the content files' do
      expect(entity(with_files: %w[file_a.csv file_b.csv]).files)
        .to contain_exactly(path('file_a.csv'),
                            path('file_b.csv'))
    end

    context 'when asked for loaded? status of associated files' do
      it 'return false if none of the files has been loaded' do
        expect(entity(with_files: ['file_a.csv', 'file_b.csv']).loaded?)
          .to be_falsey
      end

      it 'return true if all of the files has been loaded' do
        files = [{ name: 'file_a.csv', is_loaded: true },
                 { name: 'file_b.csv', is_loaded: true }]
        expect(entity(with_files: files).loaded?).to be_truthy
      end

      it 'returns the names of the files that have been loaded' do
        files = [{ name: 'file_a.csv', is_loaded: true },
                 { name: 'file_b.csv', is_loaded: false }]
        expect(entity(with_files: files).loaded?)
          .to contain_exactly path('file_a.csv')
      end
    end

    it 'returns a the entities foreign key' do
      expect(entity('example.org/Item').foreign_key).to be :item_id
    end

    it 'returns the name of the key column' do
      expect(entity(key_column: 0,
                    with_attributes: [{ name: 'key_column', index: 0 }]).key)
        .to be :key_column
    end

    context 'when returning an array of args for all associations' do
      it 'includes args for the association to self' do
        core.add_extension(term: 'example.org/ExtensionItem')
        expect(archive.core.model_associations)
          .to include a_collection_including(:many_to_one, :meta_entity,
                                             class: DwCR::MetaEntity)
      end

      context 'when it is the core' do
        let(:association) do
          core.add_extension(term: 'example.org/ExtensionItem')
          archive.core.model_associations.last
        end

        it 'has the association type many-to-one' do
          expect(association[0]).to be :one_to_many
        end

        it 'has the association name' do
          expect(association[1]).to be :extension_items
        end

        it 'has associatopm options' do
          expect(association[2]).to include(class: 'ExtensionItem',
                                            class_namespace: 'DwCR',
                                            key: :core_item_id)
        end
      end

      context 'when it is an extension, aassociation to core' do
        let :association do
          core.add_extension(term: 'example.org/XtnItem')
              .model_associations
              .last
        end

        it 'has the association type many-to-one' do
          expect(association[0]).to be :many_to_one
        end

        it 'has the association name' do
          expect(association[1]).to be :core_item
        end

        it 'has associatopm options' do
          expect(association[2]).to include(class: 'CoreItem',
                                            class_namespace: 'DwCR',
                                            key: :core_item_id)
        end
      end
    end

    it 'returns the constant with module name for the model class' do
      e = core
      DwCR.create_schema(archive)
      DwCR.load_models(archive)
      expect(e.model_get).to be DwCR::CoreItem
      DwCR::CoreItem.finalize
    end

    it 'returns a symbol for the `table_name`' do
      expect(entity('example.org/Item').table_name).to be :items
    end

    context 'when adding attributes or files from xml' do
      let(:xtn_xml) { meta_xml.css('extension').first }

      it 'adds attributes declared in the field nodes' do
        xml_attr = xtn_xml.css('field').first
        expect(entity.add_attribute_from(xml_attr).values)
          .to include(name: 'identifier',
                      term: 'example.org/terms/identifier',
                      index: 1)
      end

      it 'adds files declared in the files node' do
        e = entity
        e.add_files_from(xtn_xml)
        expect(e.files)
          .to contain_exactly(path('extension_file1.csv'),
                              path('extension_file2.csv'))
      end
    end

    context 'when updating columns based on contents' do
    let :attributes do
    	archive.load_nodes_from meta_xml
      archive.core.update_meta_attributes!(:length, :type)
      archive.core.meta_attributes.map(&:values)
    end

    it 'sets the type according to the type in the content files' do
      expect(attributes).to include(
        a_hash_including(type: 'date', term: 'example.org/terms/dateColumn')
      )
    end

    it 'sets the length according to the length in the content files' do
      expect(attributes).to include(
        a_hash_including(term: 'example.org/terms/textColumn',
                         max_content_length: 25)
      )
      end
    end
  end
end
