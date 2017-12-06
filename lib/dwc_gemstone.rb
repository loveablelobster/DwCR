# frozen_string_literal: true

require 'nokogiri'

require_relative 'schema'

#
module DwCGemstone
  #
  class DwCGemstone
    def initialize(meta_file)
      @meta = File.open(meta_file) { |f| Nokogiri::XML(f) }
      @work_dir = File.dirname(meta_file)
      @schema = Schema.new(@meta)
#       @contents = {}
#       load_core
#       load_extensions
    end

    private

#     def load_core
#       core_entity = SchemaEntity.new(@meta.css('core').first)
#       @core = core_entity.name
#       @schema[@core] = core_entity
#       @contents[@core] = TableContents.new(@work_dir, core_entity)
#     end
#
#     def load_extensions
#       @meta.css('extension').each do |extension|
#         entity = SchemaEntity.new(extension)
#         @schema[entity.name] = entity
#         @contents[entity.name] << TableContents.new(@work_dir, entity)
#       end
#     end
  end
end
