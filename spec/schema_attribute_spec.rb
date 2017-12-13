# frozen_string_literal: true

require_relative '../lib/archive_store'

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false
  end

  RSpec.describe 'SchemaAttribute' do
    before(:all) do
      @db = ArchiveStore.instance.connect('spec/files/attribute_test.db')
      @db.create_table :schema_attributes do
    	  primary_key :id
    	  column :name, :string
    	  column :alt_name, :string
    	  column :term, :string
    	  column :default, :string
    	  column :has_index, :boolean
    	  column :is_unique, :boolean
    	  column :index, :integer
        column :max_content_length, :integer
      end

      require_relative '../lib/schema_attribute'
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      extension = doc.css('extension').first
      field_nodes = extension.css('field').to_a
      field_nodes.unshift(extension.css('coreid').first)
      field_nodes.map { |field_node| DwCR.parse_field_node(field_node) }
    end

    context 'it persists SchemaAttribute objects' do
      it 'persists all nodes as SchemaAttribute objects' do
        expect(SchemaAttribute.all.count).to be 11
      end

      context 'upon initialization it presists' do
        it 'the ontological term as string' do
          expect(SchemaAttribute.all.map(&:term)).to eq([nil,
                                                         'http://purl.org/dc/terms/identifier',
                                                         'http://rs.tdwg.org/ac/terms/accessURI',
                                                         'http://purl.org/dc/terms/title',
                                                         'http://purl.org/dc/terms/format',
                                                         'http://ns.adobe.com/xap/1.0/rights/Owner',
                                                         'http://purl.org/dc/terms/rights',
                                                         'http://rs.tdwg.org/ac/terms/licenseLogoURL',
                                                         'http://ns.adobe.com/photoshop/1.0/Credit',
                                                         'http://purl.org/dc/terms/rights',
                                                         'http://purl.org/dc/elements/1.1/rights'])
          # to be nil where there is no term
          # find coreid
          # rewrite above exampe to find set
        end

        it 'the short name' do
          expect(SchemaAttribute.all.map(&:name)).to eq(['coreid',
                                                         'identifier',
                                                         'access_uri',
                                                         'title',
                                                         'format',
                                                         'owner',
                                                         'rights',
                                                         'license_logo_url',
                                                         'credit',
                                                         'rights',
                                                         'rights'])
        end

        it 'the alt_name identical to the name' do
          expect(SchemaAttribute.all.map(&:alt_name)).to eq(SchemaAttribute.all.map(&:name))
        end

        context 'the index of the column in the DwCA source file' do
          it 'an integer for the index if there is one' do
            expect(SchemaAttribute[1].index).to be 0
            expect(SchemaAttribute[2].index).to be 1
            expect(SchemaAttribute[3].index).to be 2
            expect(SchemaAttribute[4].index).to be 3
            expect(SchemaAttribute[5].index).to be 4
            expect(SchemaAttribute[6].index).to be 5
            expect(SchemaAttribute[7].index).to be 6
            expect(SchemaAttribute[8].index).to be 7
            expect(SchemaAttribute[9].index).to be 8
		      end

          it 'nil if there is no index' do
            expect(SchemaAttribute[10].index).to be_nil
            expect(SchemaAttribute[11].index).to be_nil
          end
        end

        context 'the default value' do
          it 'the default value for the column' do
            expect(SchemaAttribute[10].default).to eq '© 2008 XY Museum'
            expect(SchemaAttribute[11].default).to eq 'http://creativecommons.org/licenses/by/4.0/deed.en_US'
          end

          it 'nil if there is no default value' do
            expect(SchemaAttribute.all.map(&:default)[0..8]).to eq([nil,
                                                                    nil,
                                                                    nil,
                                                                    nil,
                                                                    nil,
                                                                    nil,
                                                                    nil,
                                                                    nil,
                                                                    nil])
          end
        end

        context 'the length of the column equal to' do
          it 'the length of the default value' do
            expect(SchemaAttribute[10].length).to be 16
            expect(SchemaAttribute[11].length).to be 53
          end

          it 'the maximum content length if given and no default set' do
          	attr = SchemaAttribute[1]
            attr.max_content_length = 32
            attr.save
            expect(attr.length).to be 32
            attr.max_content_length = nil
            attr.save
          end

          it 'the maximum content length if given and larger than the default' do
            attr = SchemaAttribute[10]
            attr.max_content_length = 100
            attr.save
            expect(attr.length).to be 100
            attr.max_content_length = nil
            attr.save
          end

          it 'the default length if longer than a given max content length' do
            attr = SchemaAttribute[11]
            attr.max_content_length = 20
            attr.save
            expect(attr.length).to be 53
            attr.max_content_length = nil
            attr.save
          end

          it 'nil if there is no default value' do
            expect(SchemaAttribute.all.map(&:length)[0..8]).to eq([nil,
                                                                   nil,
                                                                   nil,
                                                                   nil,
                                                                   nil,
                                                                   nil,
                                                                   nil,
                                                                   nil,
                                                                   nil])
          end
        end
      end
    end

    after(:all) do
      File.delete('spec/files/attribute_test.db')
    end
  end
end
