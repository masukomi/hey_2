module Granite::ORM::Querying
  def sanitize_string_for_sql(string : String) : String
    string.gsub("'", "''")
  end

  def prep_array_for_sql(strings : Array(String)) : String
    String.build do |str|
      strings.each_with_index do |string, idx|
        if idx > 0
          str << ", "
        end
        str << "'"
        str << sanitize_string_for_sql(string)
        str << "'"
      end
    end
  end
  def prep_array_for_sql(ints : Array(Int64)) : String
    String.build do |str|
      ints.each_with_index do |int, idx|
        if idx > 0
          str << ", "
        end
        str << int
      end
    end
  end

  def last(clause = "", params = [] of DB::Any)
    all([clause.strip, "ORDER BY #{@@order_column} DESC LIMIT 1"].join(" "), params).first?
  end

  macro find_or_creatable(class_name, column_name)
    def self.find_or_create_with({{column_name.id}}s : Array(String)) : Array({{class_name.id}})
      sql_names = prep_array_for_sql(names)
      all_supplied_query = "where name in (#{sql_names})"
      existing = {{class_name.id}}.all(all_supplied_query).index_by{|p|p.name}
      insertable = names - existing.keys

      if insertable.size > 0
        insert = String.build do |str|
          str << "insert into #{@@table_name} (name) values "
          insertable.each_with_index do |name, idx |
            if idx > 0
              str << ", "
            end
            str << "('"
            str << sanitize_string_for_sql(name)
            str << "')"
          end
        end
        {{class_name.id}}.exec(insert)
      end
      {{class_name.id}}.all(all_supplied_query)
    end
  end
end
