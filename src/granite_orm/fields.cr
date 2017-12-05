module Granite::ORM::Fields
  # macro included
  #   macro inherited
  #     FIELDS     = {} of Nil => Nil
  #     FIELD_COLS = {} of Nil => Nil
  #   end
  # end
  #
  # # specify the fields you want to define and types
  # macro field(decl, col=nil)
  #   {% FIELDS[decl.var] = decl.type %}
  #   {% if !col.nil? %}
  #   {% FIELD_COLS[field_name.var] = "{{column_name}}" %}
  #   {% end %}
  #   {% debug() %}
  # end

  macro no_timestamps
    {% SETTINGS[:timestamps] = false %}
  end
end
