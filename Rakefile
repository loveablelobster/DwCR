# frozen_string_literal: true

task default: %w[make_dwcr]

task :make_dwcr do
  # require sequel, connection, schematables
  require_relative 'lib/dwcr'

  path = File.join(Dir.pwd, 'test.db') # or nil

  # connect to the SQLite db
  DwCR.connect(path: path)

  # create the metaschema
  raise 'DwCR file exists' if DwCR.metaschema?
  DwCR.create_metaschema
end

task :load_dwcr do
  # require sequel, connection, schematables
  require_relative 'lib/dwcr'

  path = File.join(Dir.pwd, 'test.db') # or nil

  # FIXME: issue warning if file exists

  # connect to the SQLite db
  DwCR.connect(path: path)

  raise 'not valid DwCR' unless DwCR.metaschema?
end
