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
      #@media = SchemaEntity.new(doc.css('extension'))
    end

    it 'determines the kind' do
      expect(@core.kind).to eq(:core)
    end

    it 'gets the term' do
      expect(@core.term).to eq('http://rs.tdwg.org/dwc/terms/Occurrence')
    end

    it 'gets the columns' do
      expect(@core.attributes).to eq(Psych.load(File.open('spec/files/expected_columns.yml')))
    end

    it 'substitutes the term for duplicate column names' do pending 'not implemented'
      #
    end

    it 'gets the id colum' do
      expect(@core.key).to eq(primary: 0)
    end

    it 'determined the maximum length for each column' do pending 'questionable feature'
      #
    end

    it 'gets default values for the columns' do pending 'not implemented'
      # ideally these should be set as default values for the column in the schema
    end
  end
end
