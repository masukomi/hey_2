require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
require "../granite_orm/fields.cr"
require "../granite_orm/transactions.cr"
require "../granite_orm/querying.cr"
# require "../granite_orm/adapter/sqlite.cr"

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

		def self.list_recent(limit : Int32)
			puts "todo: output <= #{limit} recent events"
		end
		
		def self.find_by_last_or_id(identifier : String)
			event : Event?
			if identifier == "last"
				event = Event.last()
			elsif identifier.match(/^\d+$/)
				event = Event.find(identifier.to_i)
			else
				raise Exception.new("#{identifier} is not a valid event identifier")
			end
		end

		def set_created_at
			# 2017-05-26 17:33:08
			created_at = Time.now().to_s("%Y-%m-%d %H:%M:%S")
		end

		def add_tags(new_tags : Array(Hey::Tag))
			addable = new_tags - tags
			self.tags = (self.tags + addable)
		end
	end
end
