# frozen_string_literal: true

#
module DwCR
  RSpec.describe 'MetaSchema' do
    before(:all) do
      ArchiveStore.instance.connect('files/metaschema.db')
      require_relative '../lib/metaschema'
    end
  end
end
