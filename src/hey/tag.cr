require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
module Hey
	class Tag < Granite::ORM::Base
		adapter sqlite
		table_name people
		set_foreign_key tag_id
		# no_timestamps
		has_some EventTag
		# ^^ gives us an event_persons method (<class_name>.underscore + s)
		#    by underscoring EventTag and adding s
		has_some Event, through: EventTag
		# ^^ gives us an events method (<class_name>.underscore + s)
		#    by underscoring EventTag and adding s

		field name : String
	end
end
