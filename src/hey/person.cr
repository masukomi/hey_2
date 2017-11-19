# require "./interrupt_database.cr"
# require "./db_error.cr"
require "granite_orm/adapter/sqlite"
module Hey
	class Person < Granite::ORM::Base
		adapter sqlite
		table_name people
		# field id : Int64
		field name : String
		# property! name : String
		# getter :id
		
		# def initialize(@id : Int32 | Nil, @name : String)
		# end
	end
end
