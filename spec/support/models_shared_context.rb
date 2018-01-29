# frozen_string_literal: true

#
module DwCR
  RSpec.shared_context 'Models helpers' do
    let(:archive) { MetaArchive.create(path: Dir.pwd) }
    let(:meta) { 'spec/support/example_archive/meta.xml' }

    def meta_xml
      File.open(meta) { |f| Nokogiri::XML(f) }
    end

    def core_in(archive)
      archive.core = archive.add_meta_entity(term: 'example.org/CoreItem')
      archive.core.save
      archive.core
    end
  end
end
