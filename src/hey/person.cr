require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
module Hey
	class Person < Granite::ORM::Base
		adapter sqlite
		table_name people
		set_foreign_key person_id
		has_some EventPerson
		# ^^ gives us an event_persons method (<class_name>.underscore + s)
		#    by underscoring EventPerson and adding s
		has_some Event, through: EventPerson
		# ^^ gives us an events method (<class_name>.underscore + s)
		#    by underscoring EventPerson and adding s

		field name : String
	end
end
