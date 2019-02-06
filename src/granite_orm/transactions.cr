module Granite::ORM::Transactions
  macro __process_transactions
    {% primary_name = PRIMARY[:name] %}
    {% primary_type = PRIMARY[:type] %}

    # @updated_at : Time?
    # @created_at : Time?

    # The save method will check to see if the primary exists yet. If it does it
    # will call the update method, otherwise it will call the create method.
    # This will update the timestamps apropriately.
    def save
      begin
        __run_before_save
        if value = @{{primary_name}}
          __run_before_update
          {% if SETTINGS[:timestamps] %}
          @updated_at = Time.now.to_utc.to_s(SQLite3::DATE_FORMAT)
          {% end %}
          params_and_pk = params
          params_and_pk << value
          @@adapter.update @@table_name, @@primary_name, self.class.fields, params_and_pk
          __run_after_update
        else
          __run_before_create
          {% if SETTINGS[:timestamps] %}
          @created_at = Time.now.to_utc.to_s(SQLite3::DATE_FORMAT)
          @updated_at = Time.now.to_utc.to_s(SQLite3::DATE_FORMAT)
          {% end %}
          {% if primary_type.id == "Int32" %}
            @{{primary_name}} = @@adapter.insert(@@table_name, self.class.fields, params, true).to_i32
          {% else %}
            @{{primary_name}} = @@adapter.insert(@@table_name, self.class.fields, params, true)
          {% end %}
          __run_after_create
        end
        __run_after_save
        return true
      rescue ex
        if message = ex.message
          puts "Save Exception: #{message}"
          errors << Granite::ORM::Error.new(:base, message)
        end
        return false
      end
    end

    # Destroy will remove this from the database.
    def destroy
      begin
        __run_before_destroy
        @@adapter.delete(@@table_name, @@primary_name, {{primary_name}})
        __run_after_destroy
        return true
      rescue ex
        if message = ex.message
          puts "Destroy Exception: #{message}"
          errors << Granite::ORM::Error.new(:base, message)
        end
        return false
      end
    end
  end

  def create(**args)
    create(args.to_h)
  end

  def create(args : Hash(Symbol | String, DB::Any))
    instance = new
    instance.set_attributes(args)
    instance.save
    instance
  end
end
