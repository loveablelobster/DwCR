# frozen_string_literal: true

require 'psych'

#
module DwCR
  def self.create_metaschema
    connect unless Sequel::Model.db
    table_defs = Psych.load_file('lib/store/metaschema.yml')
    table_defs.each do |td|
      Sequel::Model.db.create_table? td.first do
        primary_key :id
        td.last.each { |c| column(*c) }
      end
    end
  end
end
