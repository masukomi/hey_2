require "sqlite3"
require "./config.cr"
module Hey
	class InterruptDatabase
		def initialize(@config = Config.load())
			
		end

		def get_table_for_class(x : Class)
			if x == Event
				return "events"
			elsif x == Person
				return "people"
			elsif x == EventPerson
				return "events_people"
			end
		end

		def get_event_by_id(id : Int32) : Event
			event = nil
			db_connection do | db |
				db.query "select id, description, created_at from contacts order by age desc" do |rs|
					event = Event.new(rs.read(Int32), 
								  	  rs.read(String),
								  	  rs.read(Time))
				end
			end
			return event
		end

		def is_id_valid?(x : Class, id : Int32)
			table = get_table_for_class(x)
			response = false
			db_connection do |db|
				if db.scalar "select count(*) from #{table} where id = #{id}" > 0
					response = true
				end
			end
			return response
		end

		def db_connection(&block)
			DB.open "sqlite3://#{@config.db_path}" do |db|
				yield db
				#
				#
				# db.exec "create table contacts (name string, age integer)"
				# db.exec "insert into contacts values (?, ?)", "John Doe", 30
				#
				# args = [] of DB::Any
				# args << "Sarah"
				# args << 33
				# db.exec "insert into contacts values (?, ?)", args
				#
				# puts "max age:"
				# puts db.scalar "select max(age) from contacts" # => 33
				#
				# puts "contacts:"
				# db.query "select name, age from contacts order by age desc" do |rs|
				# 	puts "#{rs.column_name(0)} (#{rs.column_name(1)})"
				# 	# => name (age)
				# 	rs.each do
				# 		puts "#{rs.read(String)} (#{rs.read(Int32)})"
				# 		# => Sarah (33)
				# 		# => John Doe (30)
				# 	end
				# end
			end
		end

		
	end
end
