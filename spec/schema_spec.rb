# frozen_string_literal: true

require 'psych'

require_relative '../lib/schema'

#
module DwCGemstone
  RSpec.describe Schema do
    before(:all) do
      @doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      @schema = Schema.new(@doc)
    end

    it 'loads the core entity' do
      expect(@schema.core.name).to eq(:occurrence)
    end

    it 'loads all extensions into an array' do
      expect(@schema.extensions).to be_an Array
      expect(@schema.extensions.length).to be 1
      expect(@schema.extensions.first.name).to be :multimedia
    end

    it 'finds an extension by name' do
    	expect(@schema.extension(:multimedia).term).to eq 'http://rs.tdwg.org/ac/terms/Multimedia'
    end

    it 'finds any entity by term or name' do
    	expect(@schema.entity('http://rs.tdwg.org/ac/terms/Multimedia').name).to be :multimedia
    	expect(@schema.entity('http://rs.tdwg.org/dwc/terms/Occurrence').name).to be :occurrence
    end

    it 'finds any entity by name' do
      expect(@schema.entity(:multimedia).term).to eq 'http://rs.tdwg.org/ac/terms/Multimedia'
    	expect(@schema.entity(:occurrence).term).to eq 'http://rs.tdwg.org/dwc/terms/Occurrence'
    end

    it 'raises and exception when trying to find an entity with an invalid argument' do
      expect { @schema.entity(1) }.to raise_error(ArgumentError, 'invalid argument: 1')
    end
  end
end
