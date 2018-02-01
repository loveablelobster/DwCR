# frozen_string_literal: true

require 'psych'

require_relative '../lib/content_analyzer/file_set'

module DwCR
  RSpec.describe FileSet do
    let(:file) { [File.path('spec/support/content_analyzer_test.csv')] }

    it 'gets the maximum lengths for each column in an array of CSV files' do
      fs = FileSet.new(file)
      expect(fs.columns).to include({ index: 0, length: 7, type: 'string' },
                                    { index: 1, length: 1, type: 'integer' },
                                    { index: 2, length: 3, type: 'float' })
    end
  end
end
