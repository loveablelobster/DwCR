# frozen_string_literal: true

require 'csv'

#
module Loadable

  def load_contents
    load_core
    load_extensions
  end

  # Load Table Contents
  def load_core
    return unless core.get_model.empty?
    files = core.content_files
    headers = core.content_headers
    path = Dir.pwd
    files.each do |file|
      filename = path + '/spec/files/' + file.name # FIXME: path!
      CSV.open(filename).each do |row|
        core.get_model.create(headers.zip(row).to_h)
      end
    end
  end

  def load_extensions
    extensions.each do |extension|
      next unless extension.get_model.empty?
      headers = extension.content_headers
      path = Dir.pwd
      extension.content_files.each do |file|
        filename = path + '/spec/files/' + file.name # FIXME: path!
        CSV.open(filename).each do |row|
          data_row = headers.zip(row).to_h
          core_instance = core.get_model
                              .first(core.key => row[extension.key_column])
          method_name = 'add_' + extension.name.singularize
          core_instance.send(method_name, data_row)
        end
      end
    end
  end
end
