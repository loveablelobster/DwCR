Gem::Specification.new do |s|
  s.name = 'dwcr'
  s.summary = 'DwCA stored in a SQLite database, with Sequel models'
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  s.requirements = ['SQLite']
  s.version = '0.0.5'
  s.author = 'Martin Stein'
  s.email = 'loveablelobster@fastmail.fm'
  s.homepage = 'https://github.com/loveablelobster/DwCR'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=2.5'
  s.files = Dir['**/**']
  s.executables = ['dwcr']
  s.licenses = ['MIT']
  s.has_rdoc = false
end
