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

  macro owned_by(parent_class_name, column=nil)
    {% underscored_class_name = parent_class_name.id.underscore %}
    {% if ! column %}
      {% column = underscored_class_name + "_id" %}
    {% end %}
    # retrieve the parent relationship
    def {{underscored_class_name}}() : {{parent_class_name}}?
      if ! {{column}}.nil?
        {{parent_class_name}}.find {{column}}
      else
        nil
      end
    end

    # set the parent relationship
    def {{parent_class_name.id.underscore}}=(a_person : Person)
      self.{{column}} = a_person.id
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
    def {{children_class_name.id.underscore}}s
      childrens_table = {{children_class_name}}.table_name
      return [] of {{children_class_name}} unless id
      table_fk_string = "#{childrens_table}.#{@@foreign_key}"
      query = "WHERE #{table_fk_string} = ?"
      {{children_class_name}}.all(query, id)
    end
  end

  macro has_some(children_class_name, through)
    def {{children_class_name.id.underscore}}s
      childrens_table = {{children_class_name.id}}.table_name
      through_table = {{through}}.table_name
      return [] of {{children_class_name}} unless id
      childrens_fk = {{children_class_name.id}}.foreign_key
      table_fk_string = "#{childrens_table}.#{@@foreign_key}"
      query = "JOIN #{through_table} ON " \
              "#{through_table}.#{childrens_fk} = #{childrens_table}.id " \
              "WHERE #{through_table}.#{@@foreign_key}= ?"
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
