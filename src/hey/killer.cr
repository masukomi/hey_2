module Hey
  class Killer
    def self.kill_command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      tag_killer    = Hey::Tag.kill_command_proc(config)
      person_killer = Hey::Person.kill_command_proc(config)
      event_killer = Hey::Event.delete_command_proc(config)
      Proc(Array(String), Bool).new { |args|
        response = true
        if args.size > 0
          if args[0] == "tag"
            response = tag_killer.call(args[1..-1])
          elsif args[0] == "event"
            response = event_killer.call(args[1..-1])
          else
            response = person_killer.call(args)
          end
        end
        response
      }
    end
    def self.kill_command_description : String
      "  hey kill <name>
  hey kill tag <tag name>
  hey kill event <last or event id>
     The first form kills the specified person (not really)
     and removes all events that only involved them. The second
     form kills the specified tag only. The third kills the
     specified event only."
    end
  end
end
