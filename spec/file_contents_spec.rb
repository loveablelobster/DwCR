# frozen_string_literal: true

require_relative '../lib/plugins/dwca_content_analyzer/file_contents'

#
module DwCAContentAnalyzer
  RSpec.describe FileContents do
    let :core do
      f = File.path('spec/support/content_analyzer_test.csv')
      FileContents.new(f).columns
    end

    it 'determines the indices as headers for each column in a CSV file' do
      indices = core.map(&:index)
      expect(indices).to contain_exactly(0, 1, 2)
    end

    it 'gets the lengths for the columns' do
      lengths = core.map(&:length)
      expect(lengths).to contain_exactly(7, 1, 3)
    end

    it 'gets the types for the columns' do
      types = core.map(&:type)
      expect(types).to contain_exactly(String, Integer, Float)
    end
  end
end
