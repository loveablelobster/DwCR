# frozen_string_literal: true

require_relative '../lib/archive_store'
require_relative '../lib/meta_parser'

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false
  end

  RSpec.describe 'SchemaEntity' do
    before(:all) do
      @db = ArchiveStore.instance.connect #('spec/files/test.db')
      doc = File.open('spec/files/meta.xml') { |f| Nokogiri::XML(f) }
      DwCR.parse_meta(doc).each { |e| DwCR.create_schema_entity(e) }
      ArchiveStore.instance.create_schema
      ArchiveStore.instance.create_models
    end

    context 'creates the schema' do
      it 'creates a table for `occurrences` (`core`)' do
        expect(@db.table_exists?(:occurrences)).to be_truthy
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

      it 'creates a table for `multimedia` (`extension`)' do
        expect(@db.table_exists?(:multimedia)).to be_truthy
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

    context 'creates the models' do
      it 'creates a model for media' do
        Multimedia.create(owner: 'me')
        expect(Multimedia[1].owner).to eq('me')
      end

      it 'creates associatiions' do
        expect(Occurrence.associations).to include(:multimedia)
        expect(Multimedia.associations).to include(:occurrence)
        obs = Occurrence.create(catalog_number: '#1')
        obs.add_multimedia(owner: 'me')
        obs.add_multimedia(owner: 'somone else')
        expect(obs.multimedia.size).to be 2
      end
    end
  end
end
