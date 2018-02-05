# frozen_string_literal: true

require_relative '../lib/metaschema/xml_parsable'
require_relative 'support/models_shared_context'

# Dummy class to test mixin
class DummyParser
  include DwCR::Metaschema::XMLParsable
end

#
RSpec.describe DwCR::Metaschema::XMLParsable do
  include_context 'Models helpers'

  let :xml_root do
    meta_xml.css('archive')
            .first
  end

  let(:dummy_parser) { DummyParser.new }

  context 'when validating the meta.xml file' do
    it 'raises an exception if the meta.xml contains multiple core nodes' do
      xml_root.add_child(Nokogiri::XML::Node.new('core',
                                                 Nokogiri::XML('<core/>')))
      expect { described_class.validate_meta(xml_root) }
        .to raise_error ArgumentError, 'Multiple Core nodes'
    end
  end

  context 'when loading the meta.xml file' do
    it 'defaults to the current working directory if no path is given' do
      m = 'No such file or directory @ rb_sysopen -'\
          " #{File.join(Dir.pwd, 'meta.xml')}"
      expect { described_class.load_meta }
        .to raise_error Errno::ENOENT, m
    end

    it 'looks for meta.xml in path if path is directory' do
      expect { described_class.load_meta(path) }.not_to raise_error
    end

    it 'loads the meta.xml given in path' do
      expect { described_class.load_meta(path('meta.xml')) }.not_to raise_error
    end
  end

  context 'when parsing field nodes' do
    let :xml do
      doc = '<field index="1" term="example.org/terms/column"'
      doc += ' default="default value"/>'
      Nokogiri::XML(doc).css('field').first
    end

    it 'retrieves the default value' do
      expect(dummy_parser.default_from(xml)).to eq 'default value'
    end

    it 'retrieves the index' do
    	expect(dummy_parser.index_from(xml)).to be 1
    end

    it 'retrieves the term' do
    	expect(dummy_parser.term_from(xml)).to eq 'example.org/terms/column'
    end

    it 'returns a hash with model fields as keys, values parsed from xml' do
      expect(dummy_parser.values_from(xml, :index, :term, :default))
        .to include index: 1,
                    term: 'example.org/terms/column',
                    default: 'default value'
    end

    it 'updates a Attribute model instance with values parsed from xml' do
    	a = entity(with_attributes: %w[column]).attributes.first
    	a.update_from xml, :index, :term, :default
    	expect(a.values).to include index: 1,
                    term: 'example.org/terms/column',
                    default: 'default value'
    end
  end

  context 'when parsing child nodes of an archive (entities)' do
    context 'when parsing the key column' do
      let :nodes do
        doc = '<archive>'
        doc += '<core><id index="0"/></core>'
        doc += '<extension><coreid index="1"/></extension>'
        doc += '</archive>'
        Nokogiri::XML(doc).css('archive').first.children
      end

      it 'retrieves the id field index for the core' do
        expect(dummy_parser.key_column_from(nodes[0])).to be 0
      end

      it 'retrieves the coreid field index for an extension' do
        expect(dummy_parser.key_column_from(nodes[1])).to be 1
      end
    end

    context 'when determining if the node is core or extension' do
      let :nodes do
        doc = '<archive><core/><extension/><invalid/></archive>'
        Nokogiri::XML(doc).css('archive').first.children
      end

      it 'returns true if the node is the core' do
      	expect(dummy_parser.is_core_from(nodes[0])).to be_truthy
      end

      it 'returns false if the node is an extension' do
      	expect(dummy_parser.is_core_from(nodes[1])).to be_falsey
      end

      it 'raises and error if the node is invalid' do
      	expect { dummy_parser.is_core_from(nodes[2]) }
      	  .to raise_error ArgumentError, 'invalid node name: \'invalid\''
      end
    end

    context 'when parsing an extension node' do
      let :extension_node do
        doc = '<extension><coreid index="0"/></extension>'
        Nokogiri::XML(doc).css('extension').first
      end

      it 'retrieves the index' do
        expect(dummy_parser.index_from(extension_node)).to be 0
      end
    end

    it 'retrieves the names for any files declared' do
    	doc = '<core><files><location>extension_file1.csv</location>'
    	doc += '<location>extension_file2.csv</location></files></core>'
    	xml = Nokogiri::XML(doc).css('core').first
    	expect(dummy_parser.files_from(xml))
    	  .to contain_exactly 'extension_file1.csv', 'extension_file2.csv'
    end

    it 'retrieves the term' do
      doc = '<archive><core rowType="http://example.org/Item"/></archive>'
    	xml = Nokogiri::XML(doc).css('core').first
    	expect(dummy_parser.term_from(xml)).to eq 'http://example.org/Item'
    end
  end

  it 'returns the XMLParsable method equivalent to the model method' do
    expect(dummy_parser.method(:term)).to eq 'term_from'
  end
end
