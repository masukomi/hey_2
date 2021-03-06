require "sandstone/adapter/sqlite"

module Hey
  class Tag < Sandstone::ORM::Base
    include Sandstone::ORM::Querying # dunno why this one needs to be included
    # but we need it for find_or_createable
    adapter sqlite
    no_timestamps
    table_name tags
    set_foreign_key tag_id
    find_or_creatable Tag, name
    # no_timestamps
    has_some EventTag
    # ^^ gives us an event_persons method (<class_name>.underscore + s)
    #    by underscoring EventTag and adding s
    has_some Event, through: EventTag
    # ^^ gives us an events method (<class_name>.underscore + s)
    #    by underscoring EventTag and adding s

    field name : String

    def self.process_instructions(instructions : Array(String))
      identifier = instructions.first.downcase
      event = Event.find_by_last_or_id(identifier)
      if !event.nil?
        tag_strings = instructions[1..-1]
        tag_objs = tag_strings.map { |tag_string|
          tag = Tag.find_by :name, tag_string.downcase
          if !tag
            tag = Tag.new(name: tag_string.downcase)
          end
          tag
        }
        event.add_tags(tag_objs)
      else
        raise Exception.new("Unable to find event with identifer: #{identifier}")
      end
    end
    def erase
      EventTag.exec("delete from events_tags where tag_id = #{id}")
      self.destroy
    end
    def self.find_or_create_from(tags_string : String) : Array(Tag)
      tag_strings = tags_string.split(/,*\s+|,$/).reject{|x|x.size == 0}.map{|x|x.downcase}
      # that handles trailing, single, double, and no comma
      Tag.find_or_create_with(tag_strings)
    end

    # -------------------------------------------------
    def self.command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      # hey tag <last|id> <tags list>
      Proc(Array(String), Bool).new { |args|
        response = true
        if args.size > 1
          id = args[0]
          tag_strings = args[1..-1].map { |t| t.downcase }
          response = Event.find_and_tag(id, tag_strings)
        else
          STDERR.puts("Usage: hey tag <\"last\" or id> <tags list>")
          response = false
        end
        response
      }
    end

    def self.command_description : String
      "  hey tag <last or id> <tag list>
    tags the event identified by \"last\" or its id
    with the tags that follow (space separated)"
    end
    def self.retag_command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      # hey retag <last|id> <tags list>
      Proc(Array(String), Bool).new { |args|
        response = true
        if args.size > 1
          last_or_id = args[0]
          tag_strings = args[1..-1].map { |t| t.downcase }
          response = Event.find_and_retag(last_or_id, tag_strings)
        else
          STDERR.puts("Usage: hey retag <\"last\" or id> <tags list>")
          response = false
        end
        response
      }

    end
    def self.retag_command_description : String
      "  hey retag <last or id> <tag list>
    replaces the tags in the event identified by \"last\"
    or its id with the tags that follow (space separated)"
    end


    # tags (plural) command stuff --------------------
    def self.tags_command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      # hey tag <last|id> <tags list>
      Proc(Array(String), Bool).new { |args|
        response = true
        if args.size == 0
          tags_string = Tag.all.map { |t| t.name }.compact.sort.join(", ")
          puts "All your tags:"
          puts tags_string
        else
          STDERR.puts("Usage: hey tags")
          response = false
        end
        response
      }
    end
    def self.kill_command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      Proc(Array(String), Bool).new { |args|
        response = true
        if args.size > 0
          tags = args.map{ |arg|
            name = arg.downcase
            t = Tag.find_by :name, name
            if ! t
              STDERR.puts "Unable to find tag with this name: #{name}"
              nil
            else
              t
            end
          }.compact.uniq

          if tags.size > 0
            tags.each do | t |
              t.erase
            end
            if tags.size == 1
              name = tags.first.name
              puts "#{name}? What's that? Never heard of it. ;)"
            else
              puts "We shall never speak of those tags again."
            end
          else
            STDERR.puts "Well, that didn't work out..."
            response = false
          end
        end
        response
      }
    end

    def self.tags_command_description : String
      "  hey tags
    lists all tags alphabetically"
    end
  end
end
