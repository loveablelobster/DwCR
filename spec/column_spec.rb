# frozen_string_literal: true

require 'date'

require_relative '../lib/content_analyzer/column'

module TableContents
  RSpec.describe Column, 'analyzes the contents of a CSV column' do
    context 'is intitialized with a `index`, `contents` and `detectors`' do
      it '`index` is required' do
        c = Column.new(1, [], :none)
        expect(c.index).to eq 1
        expect { Column.new(nil,  %w{cell1 cell2}) }.to raise_error ArgumentError
      end

      it '`contents` is an array' do
      	expect { Column.new(1, %w{cell1 cell2}) }.not_to raise_error
      	expect { Column.new(2, 'a string', :type) }.to raise_error NoMethodError
      end

      context 'accepts `detectors`' do
        it '`:none` will not trigger any detectors' do
          c = Column.new(1, %w{cell1 cell2}, :none)
          expect(c.type).to be_nil
          expect(c.length).to be_nil
        end

        it '`:length` will detect the maximum column length' do
        	c = Column.new(1, %w{cell1 cell2}, :length)
        	expect(c.length).not_to be_nil
        	expect(c.type).to be_nil
        end

        it '`:col_type` will detect the common column type' do
          c = Column.new(1, %w{cell1 cell2}, :type)
        	expect(c.type).not_to be_nil
        	expect(c.length).to be_nil
        end

        it '`[:col_length, :col_type]` will detect column length and type' do
          c = Column.new(1, %w{cell1 cell2}, :type, :length)
        	expect(c.type).not_to be_nil
        	expect(c.length).not_to be_nil
        end
      end
    end

    context 'analyzes a columns contents' do
      it 'reports the maximum length of contents (cell) met in a column' do
        c = Column.new(1, %w{a ab abc abcd abcde}, :length)
        expect(c.length).to be 5
      end

      context 'reports the columns common type' do
        it 'nil for empty columns' do
      	  c = Column.new(1, [], :type)
      	  expect(c.type).to be_nil
      	end

      	it 'the type for monotypic columns' do
      	  sc = Column.new(1, %w{cell1 cell2}, :type)
      	  expect(sc.type).to be String
      	  ic = Column.new(2, [1, 2], :type)
      	  expect(ic.type).to be Integer
      	  fc = Column.new(3, [0.5, 1.5], :type)
      	  expect(fc.type).to be Float
      	  dc = Column.new(4, [Date.new(2017,1,3), Date.new(2017,1,4)], :type)
      	  expect(dc.type).to be Date
      	end

      	it 'deafults to `Float` for mixed `Float` and `Integer` columns' do
          nc = Column.new(1, [1, 1.5], :type)
          expect(nc.type).to be Float
      	end

      	it 'defaults to `String` for mixed columns containing a string' do
      		mc = Column.new(1,
      		                [1, 'string', nil, 0.5, Date.new(2017,1,3)],
      		                :type)
      		expect(mc.type).to be String
      	end
      end
    end
  end
end
