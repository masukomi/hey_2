module Granite::ORM::Associations
  # define getter and setter for parent relationship
  macro belongs_to(model_name)
    field {{model_name.id}}_id : Int64

    # retrieve the parent relationship
    def {{model_name.id}}
      if parent = {{model_name.id.camelcase}}.find {{model_name.id}}_id
        parent
      else
        {{model_name.id.camelcase}}.new
      end
    end

    # set the parent relationship
    def {{model_name.id}}=(parent)
      @{{model_name.id}}_id = parent.id
    end
  end

  macro owned_by(parent_class_name)
    field {{parent_class_name.foreign_key}} : Int64

    # retrieve the parent relationship
    def {{parent_class.name.underscore}} : {{parent_class_name}}?
      if parent = {{parent_class_name}}.find {{parent_class_name}}.foreign_key
        parent
      else
        Nil
      end
    end

    # set the parent relationship
    def {{model_name.id}}=(parent)
      @{{model_name.id}}_id = parent.id
    end
  end



  macro has_many(children_table)
    def {{children_table.id}}
      {% children_class = children_table.id[0...-1].camelcase %}
      {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
      {% table_name = SETTINGS[:table_name] || name_space + "s" %}
      return [] of {{children_class}} unless id
      foreign_key = "{{children_table.id}}.{{table_name[0...-1]}}_id"
      query = "WHERE #{foreign_key} = ?"
      {{children_class}}.all(query, id)
    end
  end

  macro has_some(children_class_name)
    def {{children_class_name.id.underscore}}
      childrens_table = {{children_class_name}}.table_name
      return [] of {{children_class_name}} unless id
      table_fk_string = "#{childrens_table}.#{@@foreign_key}"
      query = "WHERE #{table_fk_string} = ?"
      {{children_class_name}}.all(query, id)
    end
  end

  
  # define getter for related children
  macro has_many(children_table, through)
    def {{children_table.id}}
      {% children_class = children_table.id[0...-1].camelcase %}
      {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
      {% table_name = SETTINGS[:table_name] || name_space + "s" %}
      return [] of {{children_class}} unless id
      query = "JOIN {{through.id}} ON {{through.id}}.{{children_table.id[0...-1]}}_id = {{children_table.id}}.id "
      query = query + "WHERE {{through.id}}.{{table_name[0...-1]}}_id = ?"
      {{children_class}}.all(query, id)
    end
  end
end
