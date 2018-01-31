# frozen_string_literal: true

require 'pry'

# require_relative '../lib/db/schema'

RSpec.describe 'DwCR' do
  before(:all) do
    @archive = DwCR::MetaArchive.create(path: 'spec/files')
    doc = XMLParsable.load_meta('spec/files')
    @archive.load_nodes_from(doc)
    DwCR.create_schema(@archive, type: true, length: true)
  end

  context 'creates the schema' do
    it 'creates a table for `occurrences` (`core`)' do
      expect(DB.schema(:occurrences).map(&:first)).to contain_exactly(:id,
                                                                      :meta_entity_id,
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
      expect(DB.schema(:multimedia).map(&:first)).to contain_exactly(:id,
                                                                     :meta_entity_id,
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
    expect(@archive.core.class_name).to eq 'Occurrence'
  end

  it 'fetches the extensions' do
    extensions = @archive.core.extensions_dataset
    expect(extensions).to be_a Sequel::Dataset
    expect(extensions.map(&:class_name)).to include 'Multimedia'
  end

  context 'creates the models' do
    it 'holds a list of generated models' do pending 'schema is deprecated, models to be stored in constant'
#         expect(@schema.models).to include(DwCR::Occurrence, DwCR::Multimedia)
    end

    it 'creates associations' do
      expect(DwCR::Occurrence.associations).to include(:multimedia)
      expect(DwCR::Multimedia.associations).to include(:occurrence)
      obs = DwCR::Occurrence.create(catalog_number: '#1')
      obs.add_multimedia(owner: 'me')
      obs.add_multimedia(owner: 'somone else')
      expect(obs.multimedia.size).to be 2
      obs.destroy
    end
  end

  context 'loads the data' do
    it 'loads the core with associated extension records' do
      DwCR.load_contents_for @archive
      expected_vals = { occurrence_id: 'a138e9b8-31f6-4ada-95fb-8395a41c067b',
                        catalog_number: 138601,
                        other_catalog_numbers: 'AVES-145245',
                        field_number: nil,
                        type_status: nil,
                        event_date: Date.new(2014,9,8),
                        recorded_by: 'Bolding Kristensen, Jan',
                        event_remarks: nil,
                        preparations: 'Bones - 1; Tissue - 1',
                        modified: Date.new(2016,2,8),
                        order: 'Passeriformes',
                        family: 'Cardinalidae',
                        genus: 'Piranga',
                        specific_epithet: 'ludoviciana',
                        infraspecific_epithet: nil,
                        scientific_name: 'Piranga ludoviciana',
                        continent: 'North America',
                        country: 'United States',
                        state_province: 'Texas',
                        county: 'Jeff Davis County',
                        higher_geography: 'United States, Texas, Jeff Davis County',
                        island_group: nil,
                        island: nil,
                        water_body: nil,
                        locality: 'Fort Davis',
                        location_remarks: 'Musquiz Canyon, Smithsonians´s Site; 10.4 km SE of Fort Davis',
                        decimal_longitude: -103.8333333333,
                        decimal_latitude: 30.5111111111,
                        coordinate_uncertainty_in_meters: nil,
                        geodetic_datum: 'WGS84',
                        georeferenced_date: nil,
                        sex: 'f-gonads',
                        institution_code: 'NHMD',
                        institution_id: 'http://grbio.org/cool/xxx',
                        license: 'http://creativecommons.org/licenses/by/4.0/deed.en_US',
                        access_rights: 'http://snm.ku.dk/xxx',
                        collection_code: 'AV',
                        basis_of_record: 'PreservedSpecimen',
                        dataset_name: 'Natural History Museum of Denmark ornithological collection',
                        kingdom: 'Animalia',
                        phylum: 'Chordata',
                        class: 'Aves' }
      obs1 = DwCR::Occurrence.first(catalog_number: 138601)
      expect(obs1.values).to include(expected_vals)

      obs2 = DwCR::Occurrence.first(occurrence_id: 'fd7300ee-30eb-4ec7-afec-9d3612f63f1e')
      expect(obs2.catalog_number).to be 138618
      expect(obs2.multimedia.map(&:title)).to contain_exactly('NHMD_138618 Profile','NHMD_138618 Upper side', 'NHMD_138618 Under side')
      expect(obs2.meta_entity.term).to eq 'http://rs.tdwg.org/dwc/terms/Occurrence'
#         binding.pry
    end
  end
end
