# frozen_string_literal: true

#
module DwCR
  RSpec.shared_context 'Models helpers' do
    let(:archive) { MetaArchive.create(path: Dir.pwd) }
    let(:meta) { 'spec/support/example_archive/meta.xml' }

    def meta_xml
      File.open(meta) { |f| Nokogiri::XML(f) }
    end
  end
end
