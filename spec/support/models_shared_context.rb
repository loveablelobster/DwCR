# frozen_string_literal: true

#
module DwCR
  RSpec.shared_context 'Models helpers' do
    let(:archive) { Metaschema::Archive.create(name: 'spec', path: path) }
    let(:meta) { File.join('spec', 'support', 'example_archive', 'meta.xml') }

    def path(file = nil)
      return File.join(Dir.pwd, 'spec', 'support', 'example_archive') if !file
      File.join(Dir.pwd, 'spec', 'support', 'example_archive', file)
    end

    def meta_xml
      File.open(meta) { |f| Nokogiri::XML(f) }
    end

    def core
      archive.core = archive.add_entity(term: 'example.org/CoreItem')
      archive.core.save
      archive.core
    end

    def entity(term = 'example.org/Item',
               key_column: nil,
               with_attributes: [],
               with_files: [])
      e = archive.add_entity(term: term, key_column: key_column)
      with_attributes.each do |a|
        vals = a.respond_to?(:keys) ? a : { name: a }
        e.add_attribute(vals)
      end
      with_files.each do |f|
        vals = f.respond_to?(:keys) ? f : { name: f }
        e.add_content_file(vals)
      end
      e
    end
  end
end
