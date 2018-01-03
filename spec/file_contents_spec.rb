# frozen_string_literal: true

require_relative '../lib/content_analyzer/file_contents'

module DwCR
  RSpec.describe DwCR::FileContents do
    let(:core) { FileContents.new('spec/files/occurrence.csv').columns }

    it 'detremines the indices as headers for each column in a CSV file' do
      indices = core.map(&:index)
      expect(indices).to contain_exactly(*Array.new(32) { |i| i})
    end

    it 'gets the lengths for the columns' do
      expected_lengths = [36, 6, 19, 16, 8, 10, 81, 112, 43, 10, 19, 18, 18, 20,
                          27, 49, 13, 35, 46, 29, 70, 20, 19, 11, 98, 217, 15,
                          14, 0, 5, 10, 10]
      lengths = core.map(&:length)
      expect(lengths).to contain_exactly(*expected_lengths)
    end

    it 'gets the types for the columns' do
      expected_types = [String, Integer, String, String, String, Date, String,
                        String, String, Date, String, String, String, String,
                        String, String, String, String, String, String, String,
                        String, String, String, String, String, Float, Float,
                        nil, String, Date, String]
      types = core.map(&:type)
      expect(types).to contain_exactly(*expected_types)
    end
  end
end
