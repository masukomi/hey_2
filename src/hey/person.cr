# require "./interrupt_database.cr"
# require "./db_error.cr"
require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
module Hey
	class Person < Granite::ORM::Base
		adapter sqlite
		table_name people
		set_foreign_key person_id
		has_some EventPerson
		# ^^ gives us an event_person method 
		#    by underscoring EventPerson
		#    granite doesn't provide a pluralize method so...
		
		# has_many :events, through: events_people
		# field id : Int64  - handled by granite
		field name : String

		# property! name : String
		# getter :id
		
		# def initialize(@id : Int32 | Nil, @name : String)
		# end
	end
end
