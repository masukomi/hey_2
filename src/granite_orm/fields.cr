module Granite::ORM::Fields
  macro no_timestamps
    {% SETTINGS[:timestamps] = false %}
  end
end
