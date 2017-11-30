# frozen_string_literal: true

require_relative '../lib/archive_store'
require_relative '../lib/schema_entity'

#
module DwCGemstone
  RSpec.describe SchemaEntity do
  	before(:all) do
  	  ArchiveStore.instance.connect('dwca_spec.db')
  		doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
  		@core = SchemaEntity.new(doc.css('core').first)
  	end

  	it 'determines the kind' do
  	  expect(@core.kind).to eq(:core)
  	end

  	it 'gets the term' do
  		expect(@core.term).to eq('http://rs.tdwg.org/dwc/terms/Occurrence')
  	end

  	it 'gets the columns' do pending 'not implemented'
  		#
  	end

    it 'determined the maximum length for each column' do pending 'questionable feature'
      #
    end

  	it 'gets default values for the columns' do pending 'not implemented'
  	  # ideally these should be set as default values for the column in the schema
  	end
  end
end
