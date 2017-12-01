# frozen_string_literal: true

require 'psych'

require_relative '../lib/archive_store'
require_relative '../lib/schema_entity'

#
module DwCGemstone
  RSpec.describe SchemaEntity do
    before(:all) do
#       ArchiveStore.instance.connect('dwca_spec.db')
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      @core = SchemaEntity.new(doc.css('core').first)
      @media = SchemaEntity.new(doc.css('extension').first)
    end

    context 'determines the kind' do
      it 'determines the kind' do
        expect(@core.kind).to eq(:core)
      end

      it 'raises and exception if the kind is invalid' do pending 'not implemented'
        #
      end
    end

    it 'gets the term' do
      expect(@core.term).to eq('http://rs.tdwg.org/dwc/terms/Occurrence')
    end

    context 'gets the columns' do
      it 'gets the columns' do
        expect(@core.attributes).to eq(Psych.load_file('spec/files/expected_columns.yml')['occurrence'])
      end

      it 'suffixes duplicate column names with `!`' do pending 'not implemented'
        #
      end

      it 'sets the default for existing columns' do pending 'not implemented'
        # when a name appears twice, it should check for the namespace
        # making sure it is the same column (and not substitute the term)
        # probably means rewriting the parse_fields method
        # so that it does not map the nodeset, but iterates, building an array
        # against which it checks
      end

      it 'gets the id colum' do
        expect(@core.key).to eq(primary: 0)
      end
    end

    it 'determined the maximum length for each column' do pending 'questionable feature'
      #
    end

    # move this and table building to class of it's own or as module methods
    it 'sets default values for the columns' do pending 'not implemented'
      # ideally these should be set as default values for the column in the schema
    end
  end
end
