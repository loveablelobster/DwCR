# frozen_string_literal: true

require 'pry'

require_relative '../lib/db/connection'
require_relative '../lib/meta_parser'
require_relative '../lib/store/schema'

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false
  end

  RSpec.describe Schema do
    before(:all) do
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      @dwcr = Schema.new
      DwCR.parse_meta(doc).each { |e| DwCR.create_schema_entity(e) }
      @dwcr.create_schema(col_type: true, col_length: true)
    end

    context 'creates the schema' do
      it 'creates a table for `occurrences` (`core`)' do
        expect(@db.schema(:occurrences).map(&:first)).to contain_exactly(:id,
                                                                         :occurrence_id,
                                                                         :catalog_number,
                                                                         :other_catalog_numbers,
                                                                         :field_number,
                                                                         :type_status,
                                                                         :event_date,
                                                                         :recorded_by,
                                                                         :event_remarks,
                                                                         :preparations,
                                                                         :modified,
                                                                         :order,
                                                                         :family,
                                                                         :genus,
                                                                         :specific_epithet,
                                                                         :infraspecific_epithet,
                                                                         :scientific_name,
                                                                         :continent,
                                                                         :country,
                                                                         :state_province,
                                                                         :county,
                                                                         :higher_geography,
                                                                         :island_group,
                                                                         :island,
                                                                         :water_body,
                                                                         :locality,
                                                                         :location_remarks,
                                                                         :decimal_longitude,
                                                                         :decimal_latitude,
                                                                         :coordinate_uncertainty_in_meters,
                                                                         :geodetic_datum,
                                                                         :georeferenced_date,
                                                                         :sex,
                                                                         :institution_code,
                                                                         :institution_id,
                                                                         :license,
                                                                         :access_rights,
                                                                         :collection_code,
                                                                         :basis_of_record,
                                                                         :dataset_name,
                                                                         :kingdom,
                                                                         :phylum,
                                                                         :class)
      end

      # FIXME: needs tests for type and length

      it 'creates a table for `multimedia` (`extension`)' do
        expect(@db.schema(:multimedia).map(&:first)).to contain_exactly(:id,
                                                                        :coreid,
                                                                        :identifier,
                                                                        :access_uri,
                                                                        :title,
                                                                        :format,
                                                                        :owner,
                                                                        :rights,
                                                                        :license_logo_url,
                                                                        :credit,
                                                                        :rights!,
                                                                        :occurrence_id)
      end
    end

    it 'fetches the core' do
      expect(@dwcr.core.class_name).to eq 'Occurrence'
    end

    it 'fetches the extensions' do
      extensions = @dwcr.extensions
      expect(extensions).to be_a Sequel::Dataset
      expect(extensions.map(&:class_name)).to include 'Multimedia'
    end

    context 'creates the models' do
      it 'creates associations' do
        expect(Occurrence.associations).to include(:multimedia)
        expect(Multimedia.associations).to include(:occurrence)
        obs = Occurrence.create(catalog_number: '#1')
        obs.add_multimedia(owner: 'me')
        obs.add_multimedia(owner: 'somone else')
        expect(obs.multimedia.size).to be 2
        obs.destroy
      end
    end

    context 'loads the data' do
      it 'loads the core with associated extension records' do
        @dwcr.load_contents
        obs = DwCR::Occurrence.first(occurrence_id: 'fd7300ee-30eb-4ec7-afec-9d3612f63f1e')
        expect(obs.catalog_number).to be 138618
        expect(obs.multimedia.map(&:title)).to contain_exactly('NHMD_138618 Profile','NHMD_138618 Upper side', 'NHMD_138618 Under side')
#         binding.pry
      end
    end
  end
end
