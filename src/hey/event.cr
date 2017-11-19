require "./interrupt_database"

module Hey
	class Event 
		# Event is a module in crystal so
		# i can't have any Event class.
		getter :id, :description, :created_at
		setter :description, :created_at

		def initialize(@id : Int32, @description : String, @created_at : Time)
		end

		def self.find_by_id(id : Int32) : Event
			db = InterruptDatabase.new()
			db.get_event_by_id(id)
		end

		
	end
end
