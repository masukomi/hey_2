require "./interrupt_database.cr"
require "./db_error.cr"
module Hey
	class Person
		property! name : String
		getter :id
		
		def initialize(@id : Int32 | Nil, @name : String)
		end

		def self.load(id : Int32) : Person
			database = InterruptDatabase.new()
			person = nil
			database.db_connection{|db|
				db.query "select id, name from people where id = #{id}" do |rs|
					rs.each do 
						person = Person.new(rs.read(Int32), rs.read(String))
					end
				end
			}

			if !person.nil?
				return person
			else
				raise DataError.new("no person found with id #{id}")
			end
		end
	end
end
