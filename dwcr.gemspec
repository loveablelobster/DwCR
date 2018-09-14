Gem::Specification.new do |s|
  s.name = 'dwcr'
  s.summary = 'DwCA stored in a SQLite database, with Sequel models'
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  s.requirements = ['SQLite']
  s.version = '0.0.9'
  s.author = 'Martin Stein'
  s.email = 'loveablelobster@fastmail.fm'
  s.homepage = 'https://github.com/loveablelobster/DwCR'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=2.5'
  s.add_runtime_dependency('nokogiri', '~> 1')
  s.add_runtime_dependency('psych', '~> 3')
  s.add_runtime_dependency('sequel', '~> 5')
  s.add_runtime_dependency('sqlite3', '~> 1')
  s.files = ['README.md',
             'LICENSE',
             'bin/dwcr',
             'lib/cli/help.yml',
             'lib/cli/load.rb',
             'lib/cli/new.rb',
             'lib/cli/shell.rb',
             'lib/dwca_content_analyzer/column.rb',
             'lib/dwca_content_analyzer/csv_converters.rb',
             'lib/dwca_content_analyzer/file_contents.rb',
             'lib/dwca_content_analyzer/file_set.rb',
             'lib/dwcr.rb',
             'lib/dwcr/dynamic_model_queryable.rb',
             'lib/dwcr/dynamic_models.rb',
             'lib/dwcr/inflections.rb',
             'lib/dwcr/metaschema/archive.rb',
             'lib/dwcr/metaschema/attribute.rb',
             'lib/dwcr/metaschema/content_file.rb',
             'lib/dwcr/metaschema/entity.rb',
             'lib/dwcr/metaschema/metaschema_tables.yml',
             'lib/dwcr/metaschema/metaschema.rb',
             'lib/dwcr/metaschema/xml_parsable.rb',
             'lib/dwcr/schema.rb',
             ]
  s.executables = ['dwcr']
  s.licenses = ['MIT']
  s.has_rdoc = false
end
