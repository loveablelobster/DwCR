# frozen_string_literal: true

require 'date'

require_relative '../lib/content_analyzer/column'

module DwCR
  RSpec.describe DwCR::Column, 'analyzes the contents of a CSV column' do
    context 'is intitialized with a `header`, `contents` and `detectors`' do
      it '`header` is settable' do
        c = Column.new('header', [], :none)
        expect(c.header).to eq 'header'
        c.header = :new_header
        expect(c.header).to be :new_header
      end

      it '`contents` is an array' do
      	expect { Column.new(:c, %w{cell1 cell2}) }.not_to raise_error
      	expect { Column.new(:c, 'a string') }.to raise_error NoMethodError
      end

      context 'accepts `detectors`' do
        it '`:none` will not trigger any detectors' do
          c = Column.new(:c, %w{cell1 cell2}, :none)
          expect(c.type).to be_nil
          expect(c.length).to be_nil
        end

        it '`:col_length` will detect the maximum column length' do
        	c = Column.new(:c, %w{cell1 cell2}, :col_length)
        	expect(c.length).not_to be_nil
        	expect(c.type).to be_nil
        end

        it '`:col_type` will detect the common column type' do
          c = Column.new(:c, %w{cell1 cell2}, :col_type)
        	expect(c.type).not_to be_nil
        	expect(c.length).to be_nil
        end

        it '`[:col_length, :col_type]` will detect column length and type' do
          c = Column.new(:c, %w{cell1 cell2}, %i[col_type col_length])
        	expect(c.type).not_to be_nil
        	expect(c.length).not_to be_nil
        end
      end
    end

    context 'analyzes a columns contents' do
      it 'reports the maximum length of contents (cell) met in a column' do
        c = Column.new(:c, %w{a ab abc abcd abcde}, :col_length)
        expect(c.length).to be 5
      end

      context 'reports the columns common type' do
        it 'nil for monotypic columns' do
      	  c = Column.new(:c, [], :col_type)
      	  expect(c.type).to be_nil
      	end

      	it 'the type for monotypic columns' do
      	  sc = Column.new(:strings, %w{cell1 cell2}, :col_type)
      	  expect(sc.type).to be String
      	  ic = Column.new(:ints, [1, 2], :col_type)
      	  expect(ic.type).to be Integer
      	  fc = Column.new(:floats, [0.5, 1.5], :col_type)
      	  expect(fc.type).to be Float
      	  dc = Column.new(:dates, [Date.new(2017,1,3), Date.new(2017,1,4)])
      	  expect(dc.type).to be Date
      	end

      	it 'deafults to `Float` for mixed `Float` and `Integer` columns' do
          nc = Column.new(:numeric, [1, 1.5], :col_type)
          expect(nc.type).to be Float
      	end

      	it 'defaults to `String` for mixed columns containing a string' do
      		mc = Column.new(:mixed,
      		                [1, 'string', nil, 0.5, Date.new(2017,1,3)],
      		                :col_type)
      		expect(mc.type).to be String
      	end
      end
    end
  end
end
