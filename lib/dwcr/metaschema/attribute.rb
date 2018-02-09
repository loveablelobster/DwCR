# frozen_string_literal: true

#
module DwCR
  module Metaschema

  # This class represents _field_ nodes in the DarwinCoreArchive
  # that correspond to columns in table sof the DwCA schema
  # and where applicable the ContentFile instances
  # * +type+: the column type of the node
  #   default: 'string'
  # * +name+: the name for the node
  #   default: term without namespace in underscore (snake case) form
  # * +term+: the full term (a uri), including namespace for the node
  #   see http://rs.tdwg.org/dwc/terms/index.htm
  # * +default+: the default vale for columns in the
  #   DwCA schema table
  # * +index+: the column index in the ContentFile instances
  #   associated with the Attribute instances' parent Entity instance
  # * +max_content_length+: the maximum string length of values
  #   in the corresponding column in the ContentFile instances
  #   associated with the Attribute instances' parent Entity instance
  # * *#entity*:
  #   the Entity instance the Attribute instance belongs to
  class Attribute < Sequel::Model
    include XMLParsable

    many_to_one :entity

    # Returns the last component of the term
    # will return the full term is the term is not unambiguous
    def baseterm
      unambiguous ? term&.split('/')&.last : term
    end

    # Returns a symbol for the +name+ that is
    # the name of the column in the DarwinCoreArchive schema
    def column_name
      name.to_sym
    end

    # Reurns +true+ if the _field_ node is the foreign key in the
    # _core_ or an _extension_ node in the DwCA schema, +false+ otherwise
    def foreign_key?
      index == entity.key_column && !entity.is_core
    end

    # Returns the maximum length for values in the corresponding column
    # in the DwCA schema
    # the returned value is the greater of either the length of the +default+
    # or the +max_content_length+ or +nil+ if neither is set
    def length
      [default&.length, max_content_length].compact.max
    end

    # Returns an array that can be splatted as arguments into the
    # Sequel::Schema::CreatTableGenerator#column method:
    # <tt>[name, type, options]</tt>
    def to_table_column
      col_type = type ? type.to_sym : :string
      [column_name, col_type, { index: index_options, default: default }]
    end

    alias length= max_content_length=

    private

    # Returns the index options for the Sequel database column
    # by default DwCR does not persist the foreign key field of any _extension_
    # nodes in the DwCA schema (as that relation is re-established through
    # associations) using proper SQL foreign keys
    # therefore the below else clause will never be reached in DwCR files
    # generated from an existing DarwinCoreArchive
    def index_options
      return false unless index && index == entity.key_column
      if entity.is_core
        { unique: true }
      else
        true
      end
    end
  end
  end
end
