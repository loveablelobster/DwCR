# frozen_string_literal: true

require 'psych'

# require_relative '../lib/models/schema_entity'
require_relative '../lib/table_contents'


module DwCR
  RSpec.describe TableContents do
#     before(:all) do
#       @path = 'spec/files/'
#       doc = File.open(@path + 'meta.xml') { |f| Nokogiri::XML(f) }
#       @entity = SchemaEntity.new(doc.css('extension').first)
#       @contents = TableContents.new(name: @entity.name,
#                                     path: @path,
#                                     files: @entity.contents,
#                                     headers: @entity.content_headers)
#     end
#
#     it 'has a shortname (symbol)' do
#       expect(@contents.name).to eq(:multimedia)
#     end
#
#     it 'loads all files into a CSV::Table' do
#       expect(@contents.table).to eq(CSV.table(@path + 'expected_table.csv', converters: nil))
#     end
#
#     it 'holds a reference to the generated .dwc file' do
#     	expect(@contents.file).to eq(Pathname.new('spec/files/multimedia.dwc'))
#     end
#
#     it 'determines the maximum length for each column' do
#       expect(@contents.content_lengths).to eq({ coreid: 36,
#                                                 identifier: 36,
#                                                 access_uri: 30,
#                                                 title: 22,
#                                                 format: 10,
#                                                 owner: 0,
#                                                 rights: 0,
#                                                 license_logo_url: 0,
#                                                 credit: 0 })
#     end
#
#     after(:all) do
#     	File.delete(@contents.file)
#     end
  end
end
