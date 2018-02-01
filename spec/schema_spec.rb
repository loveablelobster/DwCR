# frozen_string_literal: true

require_relative '../lib/db/schema'

RSpec.describe DwCR, 'schema methods' do
  context 'when creating the metaschema' do
    it 'creates the meta_archives table' do pending

    end

    context 'when created the meta_archives table' do
      it 'has a core_id foreign key column' do pending
#     - !ruby/sym integer
#     - !ruby/sym index: true
      end

      it 'has name column' do pending
#     - !ruby/sym name
#     - !ruby/sym string
      end

      it 'has a path column' do pending
#     - !ruby/sym path
#     - !ruby/sym string
      end

      it 'has a xmlns column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: 'http://rs.tdwg.org/dwc/text/'
      end

      it 'has a xmlns__xs column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: 'http://www.w3.org/2001/XMLSchema'
      end

      it 'has a xmlns__xsi column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: 'http://www.w3.org/2001/XMLSchema-instance'
      end

      it 'has a xsi__schema_location column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: 'http://rs.tdwg.org/dwc/text/ http://rs.tdwg.org/dwc/text/tdwg_dwc_text.xsd'
      end
    end

    context 'when creating the meta_attributes table' do
      it 'has a meta_entity_id foreign key column' do pending
#     - !ruby/sym integer
#     - !ruby/sym index: true
      end

      it 'has a type column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: string
      end

      it 'has a name column' do pending
#     - !ruby/sym string
#       !ruby/sym index: true
#       !ruby/sym null: false
      end

      it 'has a term index column' do pending
#     - !ruby/sym string
      end

      it 'has a default column' do pending
#     - !ruby/sym string
      end

      it 'has an index column' do pending
#     - !ruby/sym integer
      end

      it 'has a max_content_length column' do pending
#     - !ruby/sym integer
      end
    end

    context 'when creating the meta_entities table' do
      it 'has a meta_archive_id foreign key column' do pending
#     - !ruby/sym integer
#     - !ruby/sym index: true
      end

      it 'has a name column' do pending
#     - !ruby/sym string
#     - !ruby/sym null: false
      end

      it 'has a term column' do pending
#     - !ruby/sym term
#     - !ruby/sym string
      end

      it 'has a is_core column' do pending
#     - !ruby/sym is_core
#     - !ruby/sym boolean
      end

      it 'has a key_column column' do pending
#     - !ruby/sym integer
      end

      it 'has a fields_enclosed_by column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: '&quot;'
      end

      it 'has a fields_terminated_by column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: ','
      end

      it 'has a lines_terminated_by column' do pending
#     - !ruby/sym string
#     - !ruby/sym default: '\r\n'
      end

      it 'has a core_id foreign key column' do pending
#     - !ruby/sym integer
#     - !ruby/sym index: true
      end
    end

    context 'when creating the content_files table' do
      it 'has a meta_entity_id foreign key column' do pending
#     - !ruby/sym integer
#     - !ruby/sym index: true
      end

      it 'has a name column' do pending
#     - !ruby/sym string
      end

      it 'has a path column' do pending
#     - !ruby/sym string
      end

      it 'has a is_loaded column' do pending
#     - !ruby/sym boolean
#     - !ruby/sym default: false
      end
    end
  end

  # DwCR.create_metaschema

  # DwCR.create_schema_table(entity)

  # DwCR.add_foreign_key(table, entity)

  # DwCR.inspect_table(table, method)

  # DwCR.columns?(table, columns)

  # DWCR.indexes?(table, columns)

  # DwCR.metaschema?

end
