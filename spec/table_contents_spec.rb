# frozen_string_literal: true

require 'psych'

require_relative '../lib/table_contents'

module DwCR
  RSpec.describe 'DwCR#column_lengths' do
    let(:core_files) { ['spec/files/occurrence.csv'] }
    let(:extn_files) { ['spec/files/media.csv'] }

#     it 'gets the maximum lengths for each column in an array of CSV files' do
#       expect(DwCR.analyze(core_files)).to include(0 => { length: 36, type: String }, # A
#                                                   1 => { length: 6, type: Integer }, # B
#                                                   2 => { length: 19, type: String }, # C
#                                                   3 => { length: 16, type: String }, # D
#                                                   4 => { length: 8, type: String }, # E
#                                                   5 => { length: 10, type: Date }, # F
#                                                   6 => { length: 81, type: String }, # G
#                                                   7 => { length: 112, type: String }, # H
#                                                   8 => { length: 43, type: String }, # I
#                                                   9 => { length: 10, type: Date }, # J
#                                                   10 => { length: 19, type: String }, # K
#                                                   11 => { length: 18, type: String }, # L
#                                                   12 => { length: 18, type: String }, # M
#                                                   13 => { length: 20, type: String }, # N
#                                                   14 => { length: 27, type: String }, # O
#                                                   15 => { length: 49, type: String }, # P
#                                                   16 => { length: 13, type: String }, # Q
#                                                   17 => { length: 35, type: String }, # R
#                                                   18 => { length: 46, type: String }, # S
#                                                   19 => { length: 29, type: String }, # T
#                                                   20 => { length: 70, type: String }, # U
#                                                   21 => { length: 20, type: String }, # V
#                                                   22 => { length: 19, type: String }, # W
#                                                   23 => { length: 11, type: String }, # X
#                                                   24 => { length: 98, type: String }, # Y
#                                                   25 => { length: 217, type: String }, # Z
#                                                   26 => { length: 15, type: Float }, # AA
#                                                   27 => { length: 14, type: Float }, # AB
#                                                   28 => { length: 0, type: nil }, # AC
#                                                   29 => { length: 5, type: String }, # AD
#                                                   30 => { length: 10, type: Date }, # AE
#                                                   31 => { length: 10, type: String }) # AF
#
#       expect(DwCR.analyze(extn_files)).to include(0 => { length: 36, type: String }, # A
#                                                   1 => { length: 36, type: String }, # B
#                                                   2 => { length: 30, type: String }, # C
#                                                   3 => { length: 22, type: String }, # D
#                                                   4 => { length: 10, type: String }, # E
#                                                   5 => { length: 0, type: nil },  # F
#                                                   6 => { length: 0, type: nil },  # G
#                                                   7 => { length: 0, type: nil },  # H
#                                                   8 => { length: 0, type: nil })  # I
#     end

    it 'consolidates arrays of hashes' do
      a = [{ length: 10, type: String }]
      expect(DwCR.consolidate(a)).to eq({ length: 10, type: String })

      b = [{ length: 3, type: Integer }, { length: 5, type: Float }]
      expect(DwCR.consolidate(b)).to eq({ length: 5, type: Float })

      c = [{ length: 10, type: String }, { length: 5, type: Integer }, { length: 11, type: Float }, {length: 32, type: String }, {length: 0, type: nil }]
      expect(DwCR.consolidate(c)).to eq({ length: 32, type: String })
    end
  end
end
