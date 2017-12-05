module Granite::ORM::Table
  macro included
    macro inherited
      SETTINGS = {} of Nil => Nil
      PRIMARY = {name: id, type: Int64}
    end
  end

  # specify the database adapter you will be using for this model.
  # mysql, pg, sqlite, etc.
  macro adapter(name)
    @@adapter = Granite::Adapter::{{name.id.capitalize}}.new("{{name.id}}")

    def self.adapter
      @@adapter
    end
  end

  # specify the table name to use otherwise it will use the model's name
  macro table_name(name)
    {% SETTINGS[:table_name] = name.id %}
  end

  macro set_foreign_key(column)
    {% SETTINGS[:foreign_key] = column.id %}
  end

  macro set_order_column(column)
    {% SETTINGS[:order_column] = column.id %}
  end

  # specify the primary key column and type
  macro primary(decl)
    {% PRIMARY[:name] = decl.var %}
    {% PRIMARY[:type] = decl.type %}
  end

  macro __process_table
    {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
    {% table_name = SETTINGS[:table_name] || name_space + "s" %}
    {% primary_name = PRIMARY[:name] %}
    {% primary_type = PRIMARY[:type] %}
    {% foreign_key = SETTINGS[:foreign_key] || table_name + "_id" %}
    # Table Name
    @@table_name = "{{table_name}}"
    @@primary_name = "{{primary_name}}"
    @@foreign_key = "{{foreign_key}}"
    @@order_column = "{{SETTINGS[:order_column] || "id".id}}"

    def self.table_name : String
      @@table_name
    end
    def self.foreign_key : String
      @@foreign_key
    end
    # Create the primary key
    property {{primary_name}} : Union({{primary_type.id}} | Nil)

    def self.count() : Int64
      self.scalar("select count(*) from {{table_name}}"){|x| x}.as(Int64)
    end
  end
end
