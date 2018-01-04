# frozen_string_literal: true

require 'psych'

require_relative '../lib/content_analyzer/file_set'

module DwCR
  RSpec.describe FileSet do
    let(:core_files) { ['spec/files/occurrence.csv'] }
    let(:extn_files) { ['spec/files/media.csv'] }

    it 'gets the maximum lengths for each column in an array of CSV files' do
      core = FileSet.new(core_files)
      expect(core.columns).to include({ index: 0, length: 36, type: String }, # A
                                      { index: 1, length: 6, type: Integer }, # B
                                      { index: 2, length: 19, type: String }, # C
                                      { index: 3, length: 16, type: String }, # D
                                      { index: 4, length: 8, type: String }, # E
                                      { index: 5, length: 10, type: Date }, # F
                                      { index: 6, length: 81, type: String }, # G
                                      { index: 7, length: 112, type: String }, # H
                                      { index: 8, length: 43, type: String }, # I
                                      { index: 9, length: 10, type: Date }, # J
                                      { index: 10, length: 19, type: String }, # K
                                      { index: 11, length: 18, type: String }, # L
                                      { index: 12, length: 18, type: String }, # M
                                      { index: 13, length: 20, type: String }, # N
                                      { index: 14, length: 27, type: String }, # O
                                      { index: 15, length: 49, type: String }, # P
                                      { index: 16, length: 13, type: String }, # Q
                                      { index: 17, length: 35, type: String }, # R
                                      { index: 18, length: 46, type: String }, # S
                                      { index: 19, length: 29, type: String }, # T
                                      { index: 20, length: 70, type: String }, # U
                                      { index: 21, length: 20, type: String }, # V
                                      { index: 22, length: 19, type: String }, # W
                                      { index: 23, length: 11, type: String }, # X
                                      { index: 24, length: 98, type: String }, # Y
                                      { index: 25, length: 217, type: String }, # Z
                                      { index: 26, length: 15, type: Float }, # AA
                                      { index: 27, length: 14, type: Float }, # AB
                                      { index: 28, length: 0, type: nil }, # AC
                                      { index: 29, length: 5, type: String }, # AD
                                      { index: 30, length: 10, type: Date }, # AE
                                      { index: 31, length: 10, type: String }) # AF

      extension = FileSet.new(extn_files)
      expect(extension.columns).to include({ index: 0, length: 36, type: String }, # A
                                           { index: 1, length: 36, type: String }, # B
                                           { index: 2, length: 30, type: String }, # C
                                           { index: 3, length: 22, type: String }, # D
                                           { index: 4, length: 10, type: String }, # E
                                           { index: 5, length: 0, type: nil },  # F
                                           { index: 6, length: 0, type: nil },  # G
                                           { index: 7, length: 0, type: nil },  # H
                                           { index: 8, length: 0, type: nil })  # I
    end
  end
end
