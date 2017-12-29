# frozen_string_literal: true

require 'psych'

require_relative '../lib/table_contents'

module DwCR
  RSpec.describe 'DwCR#column_lengths' do
    let(:core_files) { ['spec/files/occurrence.csv'] }
    let(:extn_files) { ['spec/files/media.csv'] }

    it 'gets the maximum lengths for each column in an array of CSV files' do
      expect(DwCR.analyze(core_files)).to include(0 => { length: 36, type: nil },
                                                  1 => { length: 6, type: nil },
                                                  2 => { length: 19, type: nil },
                                                  3 => { length: 16, type: nil },
                                                  4 => { length: 8, type: nil },
                                                  5 => { length: 10, type: nil },
                                                  6 => { length: 81, type: nil },
                                                  7 => { length: 112, type: nil },
                                                  8 => { length: 43, type: nil },
                                                  9 => { length: 10, type: nil },
                                                  10 => { length: 19, type: nil },
                                                  11 => { length: 18, type: nil },
                                                  12 => { length: 18, type: nil },
                                                  13 => { length: 20, type: nil },
                                                  14 => { length: 27, type: nil },
                                                  15 => { length: 49, type: nil },
                                                  16 => { length: 13, type: nil },
                                                  17 => { length: 35, type: nil },
                                                  18 => { length: 46, type: nil },
                                                  19 => { length: 29, type: nil },
                                                  20 => { length: 70, type: nil },
                                                  21 => { length: 20, type: nil },
                                                  22 => { length: 19, type: nil },
                                                  23 => { length: 11, type: nil },
                                                  24 => { length: 98, type: nil },
                                                  25 => { length: 217, type: nil },
                                                  26 => { length: 15, type: nil },
                                                  27 => { length: 14, type: nil },
                                                  28 => { length: 0, type: nil },
                                                  29 => { length: 5, type: nil },
                                                  30 => { length: 10, type: nil },
                                                  31 => { length: 10, type: nil })
      expect(DwCR.analyze(extn_files)).to include(0 => { length: 36, type: nil },
                                                  1 => { length: 36, type: nil },
                                                  2 => { length: 30, type: nil },
                                                  3 => { length: 22, type: nil },
                                                  4 => { length: 10, type: nil },
                                                  5 => { length: 0, type: nil },
                                                  6 => { length: 0, type: nil },
                                                  7 => { length: 0, type: nil },
                                                  8 => { length: 0, type: nil })
    end
  end
end
