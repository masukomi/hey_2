require "granite_orm/adapter/sqlite"
require "../granite_orm/fields.cr"
require "../granite_orm/transactions.cr"

module Hey
	class Event < Granite::ORM::Base
		adapter sqlite
		table_name events
		no_timestamps
		# has_many :event_persons
		# has_many :people, through: event_persons

		# field id : Int64
		field description : String?
		field created_at : String

		before_create :set_created_at

		def set_created_at
			# 2017-05-26 17:33:08
			created_at = Time.now().to_s("%Y-%m-%d %H:%M:%S")
		end
	end
end
