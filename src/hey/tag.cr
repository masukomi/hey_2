require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
module Hey
	class Tag < Granite::ORM::Base
		adapter sqlite
		table_name tags
		set_foreign_key tag_id
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
				tag_objs = tag_strings.map{|tag_string|
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

		#-------------------------------------------------
		def self.command_proc : Proc(Array(String), Bool)
			# hey tag <last|id> <tags list>
			Proc(Array(String), Bool).new{ |args|
				response = true
				if args.size > 1
					id = args[0]
					tag_strings = args[1..-1].map{|t|t.downcase}
					response = Event.find_and_tag(id, tag_strings)
				else
					STDERR.puts("Usage: hey tag <\"last\" or id> <tags list>")
					response = false
				end
				response
			}
		end
		def self.command_description() : String
"  hey tag <last or id> <tag list>
    tags the event identified by \"last\" or its id
    with the tags that follow (space separated)"
		end
	end
end
