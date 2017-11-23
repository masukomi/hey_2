require "granite_orm/adapter/sqlite"
require "../granite_orm/associations.cr"

module Hey
	class EventPerson < Granite::ORM::Base
		adapter sqlite
		table_name events_people
		# field event_id  : Int64
		# field person_id : Int64
		belongs_to person
		# ^^ gives us a .person method
		belongs_to event
		# belongs_to :event
	end
end
