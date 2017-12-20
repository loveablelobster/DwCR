# frozen_string_literal: true

require 'psych'

require_relative '../lib/table_contents'


module DwCR
  RSpec.describe 'DwCR#column_lengths' do
    let(:core_files) { ['spec/files/occurrence.csv'] }
    let(:extn_files) { ['spec/files/media.csv'] }

    it 'gets the maximum lengths for each column in an array of CSV files' do
    	expect(DwCR.column_lengths(core_files)).to include(0=>36,
                                                         1=>6,
                                                         2=>19,
                                                         3=>16,
                                                         4=>8,
                                                         5=>10,
                                                         6=>81,
                                                         7=>112,
                                                         8=>43,
                                                         9=>10,
                                                         10=>19,
                                                         11=>18,
                                                         12=>18,
                                                         13=>20,
                                                         14=>27,
                                                         15=>49,
                                                         16=>13,
                                                         17=>35,
                                                         18=>46,
                                                         19=>29,
                                                         20=>70,
                                                         21=>20,
                                                         22=>19,
                                                         23=>11,
                                                         24=>98,
                                                         25=>217,
                                                         26=>15,
                                                         27=>14,
                                                         28=>0,
                                                         29=>5,
                                                         30=>10,
                                                         31=>10)
    	expect(DwCR.column_lengths(extn_files)).to include(0 => 36,
                                                         1 => 36,
                                                         2 => 30,
                                                         3 => 22,
                                                         4 => 10,
                                                         5 => 0,
                                                         6 => 0,
                                                         7 => 0,
                                                         8 => 0)
    end
  end
end
