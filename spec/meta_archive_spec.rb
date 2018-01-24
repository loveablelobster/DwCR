# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
    config.warnings = false

    config.around(:example) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'MetaArchive' do
    let(:archive) { MetaArchive.create(path: Dir.pwd) }
    it 'ensures the' do
      archive.core = archive.add_meta_entity(term: 'example.org/core')
      expect(archive.core.is_core).to be_truthy
    end
  end
end
