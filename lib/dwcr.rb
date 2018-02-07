require 'csv'
require 'json'
require 'nokogiri'
require 'psych'
require 'sequel'
require 'sqlite3'

require_relative 'dwca_content_analyzer/file_set'
require_relative 'dwcr/dynamic_model_queryable'
require_relative 'dwcr/dynamic_models'
require_relative 'dwcr/metaschema/metaschema'
require_relative 'dwcr/schema'

Sequel.extension :inflector
require_relative 'dwcr/inflections'
