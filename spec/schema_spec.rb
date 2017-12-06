# frozen_string_literal: true

require 'psych'

require_relative '../lib/schema'

#
module DwCGemstone
  RSpec.describe Schema do
    before(:all) do
      @doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      @schema = Schema.new(@doc)
#       @core = SchemaEntity.new(@doc.css('core').first)
#       @media = SchemaEntity.new(@doc.css('extension').first)
    end

    it 'loads the core entity' do
      expect(@schema.core.name).to eq(:occurrence)
    end
  end
end
