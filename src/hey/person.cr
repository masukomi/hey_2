require "granite_orm/adapter/sqlite"
require "../granite_orm/table.cr"
require "../granite_orm/associations.cr"
require "../granite_orm/querying.cr"

# require "./reports/people_report.cr"

module Hey
  class Person < Granite::ORM::Base
    include Granite::ORM::Querying # dunno why this one needs to be included
    adapter sqlite
    table_name people
    set_foreign_key person_id
    set_order_column name
    find_or_creatable Person, name
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
      (0..days_back).to_a.reverse.each do |num|
        date_string = num.days.ago.to_s("%Y-%m-%d")
        result << (data.has_key?(date_string) ? data[date_string] : zero)
      end
      result
    end

    def events_by_day(days_back : Int32) : Hash(String, Int64)
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

    def erase
      event_ids_query = "select e.id,
      ( select count(*) from events_people where events_people.event_id = e.id) epc
      from
      events e
      inner join events_people ep on ep.event_id = e.id
      inner join people p on ep.person_id = p.id
      where epc = 1
      and p.id = ?
      group by 1;"
      eids = Array(Int64).new
      Event.query(event_ids_query, [self.id]) do |rs|
        rs.each do
          eids << rs.read(Int64)
        end
      end
      Event.exec("delete from events where id in (#{prep_array_for_sql(eids)})")
      self.destroy
    end

    def self.find_or_create_from(people_string : String) : Array(Person)
      names = people_string.split(/,*\s+|,$/).reject{|x|x.size == 0}.map{|x|x.downcase}
      # that handles trailing, single, double, and no comma
      Person.find_or_create_with(names)
    end
    # ----------------------------------
    def self.kill_command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      Proc(Array(String), Bool).new { |args|
        response = true
        if args.size > 0
          people = args.map{ |arg|
            name = arg.downcase
            p = Person.find_by(:name, name)
            if ! p
              STDERR.puts "Unable to find person with this name: #{name}"
              nil
            else
              p
            end
          }.compact.uniq

          if people.size > 0
            people.each do | p |
              # yes, this is many slow deletes
              # realistically it's going to like 1-5 so I don't care.
              p.erase
            end
            if people.size == 1
              name = people.first.name
              puts "#{name} is dead! Long live #{name}!"
            else
              puts "We shall never speak of them again."
            end
          else
            STDERR.puts "Well, that didn't work out..."
            response = false
          end
        end
        response
      }
    end

    # def self.kill_command_description : String
    #   "  hey kill <name>
    #  kills the specified person (not really)
    #  and removes all events that only involved them."
    # end
  end
end
