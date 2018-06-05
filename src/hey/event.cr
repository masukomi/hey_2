require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
require "../granite_orm/fields.cr"
require "../granite_orm/transactions.cr"
require "../granite_orm/querying.cr"
# require "../granite_orm/adapter/sqlite.cr"
require "sqlite3"
require "crystal_fmt"

module Hey
  class Event < Granite::ORM::Base
    adapter sqlite
    table_name events
    set_foreign_key event_id
    set_order_column created_at
    no_timestamps # because granite ORM can't handle sqlite timestamps
    has_some EventPerson
    # has_many :event_persons
    # has_many :people, through: event_persons
    has_some Person, through: EventPerson
    # gives us a .persons method
    has_some EventTag
    has_some Tag, through: EventTag
    # gives us a .tags method

    # field id : Int64
    field description : String?
    field created_at : String

    before_create :set_created_at

    # Outputs a table of recent events:
    # Example:
    # Here are the last <limit> recent events:
    #
    # ID | Who       | When                 | Tags
    # 2. | Bob, Mary | 4/12/17 14:23        | meeting, scheduled
    # 3. | Bob       | 4/12/17 14:26        |
    # 4. | Sam       | 4/12/17 16:11        | question
    # 5. | Mary      | 4/12/18 09:22        | task list
    def self.list_recent(limit : Int32 = 25)
      recent = Event.all("ORDER BY #{@@order_column} DESC LIMIT #{limit}")
      if recent.size > 0
        data = Array(Array(String | Nil)).new
        data << ["ID", "Who", "When", "Tags"]
        recent.each do |event|
          data << [
            event.id.to_s,
            event.persons.map { |p| p.name }.join(", "),
            event.created_at, # is a string in sqlite
            event.tags.map { |t| t.name }.join(", "),
          ]
        end
        t = Table.new(data)
        puts "Here are the last #{limit} recent events:\n"
        puts t.format
      else
        puts "No recent events found."
        puts "Should I be happy that no-one interrupts you,"
        puts "or sad because something isn't right?"
      end
    end

    def self.find_by_last_or_id(identifier : String) : Event?
      event : Event?
      if identifier == "last"
        event = Event.last
      elsif identifier.match(/^\d+$/)
        event = Event.find(identifier.to_i)
      else
        raise Exception.new("#{identifier} is not a valid event identifier")
      end
    end

    def set_created_at(t : Time = Time.now) : Event
      # 2017-05-26 17:33:08
      self.created_at = t.to_s(SQLite3::DATE_FORMAT)
      self
    end
    def set_created_at!(t : Time = Time.now) : Event
      set_created_at(t).save
      self
    end
    def get_created_at_time() : Time?
      return nil if self.created_at.nil?
      Time.parse(self.created_at.to_s, SQLite3::DATE_FORMAT)
    end

    def add_tags(new_tags : Array(Hey::Tag)) : Event
      addable = new_tags - tags
      self.tags = (self.tags + addable)
      self
    end
    def add_tags(new_tag_strings : Array(String)) : Event
      add_tags(strings_to_tags(new_tag_strings))
    end
    def add_tags!(new_tag_strings : Array(String)) : Event
      add_tags(new_tag_strings).save
      self
    end

    def to_simple_string() : String
      people_list = self.persons.map{|p|p.name.to_s}.join(", ")
      tags_list = self.tags.map{|t|t.name.to_s}.join(", ")
      tags_list = "No Tags" if tags_list.size == 0
      "Event #{self.id}:
  time:   #{self.created_at}
  people: #{people_list}
  tags:   #{tags_list}"
    end

    def clear_tags!()
      self.tags = Array(Tag).new()
      self.save
    end

    def self.find_and_tag(last_or_id : String, tag_strings : Array(String)) : Bool
      event = Event.find_by_last_or_id(last_or_id)
      if event
        event.add_tags!(tag_strings)
        return true
      else
        STDERR.puts("Unable to find Event with that identifier: #{last_or_id}")
        return false
      end
    end
    def self.find_and_retag(last_or_id : String, tag_strings : Array(String)) : Bool
      event = Event.find_by_last_or_id(last_or_id)
      if event
        event.as(Event).retag!(tag_strings)
        return true
      else
        STDERR.puts("Unable to find Event with that identifier: #{last_or_id}")
        return false
      end
    end

    def self.create_from_args(args) : Event
      names = Array(String).new
      tags = Array(String).new
      tags_arg = false
      args.map { |a| a.downcase }.each do |arg|
        if arg == "+" || arg == "tag"
          if (names.size > 0)
            tags_arg = true
          else
            STDERR.puts("you must specify names for the event before tags")
          end
        elsif !tags_arg
          names << arg
        else
          tags << arg
        end
      end
      people = Person.find_or_create_with(names)
      tags = Tag.find_or_create_with(tags)
      create_for(people, tags)
    end

    def self.create_for(people : Array(Person), tags : Array(Tag)) : Event
      e = Event.new
      e.persons = people
      e.tags = tags
      e
    end

    def retag(tag_strings : Array(String)) : Event
      clear_tags!
      add_tags(tag_strings)
    end
    def retag(tags : Array(Hey::Tag)) : Event
      clear_tags!
      add_tags(tags)
    end
    def retag!(tag_strings : Array(String)) : Event
      retag(tag_strings).save
      self
    end
    def retag!(tags : Array(Hey::Tag)) : Event
      retag(tags).save
      self
    end

    private def strings_to_tags(tag_strings : Array(String)) : Array(Hey::Tag)
      tag_strings.map { |string|
        t = Tag.find_by :name, string
        if t.nil?
          t = Tag.new
          t.name = string
          t.save
        end
        t
      }
    end
    # -----------------------------------
    # LIST
    def self.command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      Proc(Array(String), Bool).new { |args|
        limit = 25
        if args.size > 0
          limit = args.first.to_i
        end
        Event.list_recent(limit)
        true
      }
    end

    def self.command_description : String
      "  hey list [number]
     lists recent events
     defaults to 25"
    end

    # ----------------------------------
    # DELETE
    def self.delete_command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      Proc(Array(String), Bool).new { |args|
        response = true
        if args.size > 0
          events = args.map{ |arg|
            lid = arg.downcase
            e = Event.find_by_last_or_id(lid)
            if ! e
              STDERR.puts "Unable to find event with this identifier: #{lid}"
              nil
            else
              e
            end
          }.compact.uniq

          if events.size > 0
            events.each do | e |
              # yes, this is many slow deletes
              # realistically it's going to like 1-5 so I don't care.
              e.destroy
            end
            # for humor
            insertion = ""
            if events.size == 1
              insertion = events.first.id.to_s
            else
              insertion = "them"
            end
            puts "We shall never speak of #{insertion} again."

          else
            STDERR.puts "Well, that didn't work out..."
            response = false
          end
        end
        response
      }
    end

    def self.delete_command_description : String
      "  hey delete <last or id>
     deletes the event specified by
     \"last\" or an id"
    end


    # ----------------------------------
    # EDIT
     def self.edit_command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      Proc(Array(String), Bool).new { |args|
        limit = 25
        lid = args.first
        if args.size > 0
          e = Event.find_by_last_or_id(lid)
          if ! e.nil?
            ee = EventEditor.new(e.as(Event))
            ee.interrogate!
            true
          else
            STDERR.puts "Unable to find event with this identifier: #{lid}"
            false
          end
        else
          false
        end
      }
    end

    def self.edit_command_description : String
      "  hey edit <last or id>
     edits the specified event"
    end

  end
end
