require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
module Hey
	class Person < Granite::ORM::Base
		adapter sqlite
		table_name people
		set_foreign_key person_id
		set_order_column name
		has_some EventPerson
		# ^^ gives us an event_persons method (<class_name>.underscore + s)
		#    by underscoring EventPerson and adding s
		has_some Event, through: EventPerson
		# ^^ gives us an events method (<class_name>.underscore + s)
		#    by underscoring EventPerson and adding s

		field name : String

		def event_counts_per_day(days_back : Int32 = 14) : Array(Int64)
			
			data = events_by_day(days_back)
			# if you've only had one event in the past n days 
			# then that data will only contain 1 entry
			# we need to calculate every day in the past <days_back>
			# days, then iterate over that list
			result = Array(Int64).new
			# can't do descending ranges
			zero = Int64.new(0)
			(0..days_back).to_a.reverse.each do | num |
				date_string =  num.days.ago.to_s("%Y-%m-%d")
				result << (data.has_key?(date_string) ? data[date_string] : zero)
			end
			result
			

		end
		private def events_by_day(days_back : Int32) : Hash(String, Int64)
			query = "select strftime('%Y-%m-%d', e.created_at) days, count(*)
num_per_day 
FROM people p 
INNER JOIN events_people ep ON ep.person_id = p.id
INNER JOIN events e ON ep.event_id = e.id
WHERE p.id = ?
AND e.created_at BETWEEN datetime('now', '-#{days_back} days') 
AND datetime('now', 'localtime')
GROUP BY days"
			
			data = Hash(String, Int64).new
			Person.query(query, [self.id]) do |rs|
				rs.each do
					data[rs.read(String)] = rs.read(Int64)
				end
			end
			data
		end
		
		def self.people_info() : Array(Array(String|Nil))
			sparker = Sparker.new()
			peeps = Person.all("ORDER BY name ASC") # default sorted by name
			query = "select p.id, t.name
from people p
inner join events_people ep on ep.person_id = p.id
left outer join events_tags et on et.event_id = ep.event_id
left outer join tags t on et.tag_id = t.id
order by p.name, ep.event_id;"
			person_to_tags = Hash(Int64,Set(String)).new
			Person.query(query) do |rs|
				rs.each do
					pid = rs.read(Int64)
					if !person_to_tags.has_key? pid
						person_to_tags[pid] = Set(String).new 
					end
					begin 
						person_to_tags[pid] << rs.read(String)
					rescue
					end
				end
			end

			data = Array(Array(String|Nil)).new
			data << ["Who", "Recent Activity", "Tags"]
			peeps.each do | p |
				sparkline = sparker.generate(p.event_counts_per_day())
				tags = person_to_tags.has_key?(p.id) ?  person_to_tags[p.id].join(", ") : ""
				data << [p.name, sparkline, tags]
			end
			data
		end

		def self.find_or_create_from_names(names : Array(String)) : Array(Person)
			sql_names = prep_array_for_sql(names)
			all_supplied_query = "where name in (#{sql_names})"
			existing = Person.all(all_supplied_query).index_by{|p|p.name}
			insertable = names - existing.keys

			if insertable.size > 0
				insert = String.build do |str|
					str << "insert into people (name) values "
					insertable.each_with_index do |name, idx | 
						if idx > 0
							str << ", "
						end
						str << "('"
						str << sanitize_string_for_sql(name)
						str << "')"
					end
				end
				Person.exec(insert)
			end
			Person.all(all_supplied_query)
		end

		#-------------------------
		def self.people_command_proc : Proc(Array(String), Bool)
			# hey tag <last|id> <tags list>
			Proc(Array(String), Bool).new{ |args|
				response = true
				if args.size == 0
					t = Table.new(Person.people_info())
					puts "People, 14 days of activity, & tags"
					puts t.format
				else
					STDERR.puts("Usage: hey people")
					response = false
				end
				response
			}
		end
		def self.people_command_description() : String
"  hey people
    lists all the people you've interacted with,
    their activity, and the tags associated with it."
		end

	end
end
