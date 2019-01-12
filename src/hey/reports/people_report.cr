require "option_parser"
require "../config.cr"
require "sparker"
config = Hey::Config.load
require "./report.cr"
require "../*"
require "../../granite_orm/querying.cr"
require "crystal_fmt"

module Hey
  module Reports
    class PeopleReport < Hey::Reports::Report
      include Sparkline
      include Hey
      include Granite::ORM::Querying # dunno why this one needs to be included
      MAX_AGE_IN_DAYS=14

      getter :name, :description, :db_version, :location
      def initialize()
        @name = "people_overview"
        @description = "Generates a table with all the people you've
interacted with, their recent activity, and tags."
        @version = Hey::VERSION
        @location = nil.as(String?)
      end
      def run(db_path : String | Nil)
        # vvv should never be needed
        if db_path.nil? && !ENV.has_key? "DATABASE_URL"
          config = Hey::Config.load
        end
        data = generate_data()
        if data.size > 0
          t = Table.new(data)
          puts "People, #{MAX_AGE_IN_DAYS} days of activity, & tags"
          puts t.format
        else
          puts "No interrupts within the past #{MAX_AGE_IN_DAYS} days."
        end
      end

      def generate_data : Array(Array(String | Nil))
        sparker = Sparker.new(Sparkline::Sparker::TICKS_2)
        query = "select p.id, t.name
  from people p
  inner join events_people ep on ep.person_id = p.id
  inner join events e on ep.event_id = e.id
  left outer join events_tags et on et.event_id = ep.event_id
  left outer join tags t on et.tag_id = t.id
  where e.created_at > '#{MAX_AGE_IN_DAYS.days.ago.to_s("%Y-%m-%d")}'
  order by p.name, ep.event_id;"

        # STDERR.puts("running query\n#{query}")
        person_to_tags = Hash(Int64, Set(String)).new
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
        data = Array(Array(String | Nil)).new
        if person_to_tags.size > 0
          peeps_query = "WHERE id in (#{prep_array_for_sql(person_to_tags.keys)})"
          peeps = Person.all(peeps_query)
          data << ["Who", "Recent Activity", "Tags"]
          peeps.each do |p|
            sparkline = sparker.generate(p.event_counts_per_day)
            tags = person_to_tags.has_key?(p.id) ? person_to_tags[p.id].join(", ") : ""
            data << [p.name, sparkline, tags]
          end
        end
        data
      end
    end
  end
end

### You'd do this if it was running as a separated executable
# if File.basename(PROGRAM_NAME) == "people_report"
#   handled = false
#   parser = OptionParser.new do |parser|
#     parser.banner = "Usage: --info"
#     parser.on("-i", "--info", "Returns a JSON string describing this report") {
#       handled = true
#       data = Hash(String, String).new
#       data["name"] = "people_overview"
#       data["description"] = \
#          "Generates a table with all the people you've
#   interacted with, their recent activity, and tags."
#     data["db_version"] = "2.0"
#
#     json = String.build { |x| data.to_json(x) }
#     puts json
#     }
#     parser.on("-d path", "--database=path", "Specifies the path to the SQLite
#     DB") { |path|
#       handled = true
#       if File.exists?(path)
#         # ENV["DATABASE_URL"]="sqlite3:#{path}"
#         config.set_db_path(path.to_s)
#         pr = Hey::Reports::PeopleReport.new
#         pr.run
#       else
#         STDERR.puts("unable to find db at #{path}")
#         exit 1
#       end
#     }
#   end
#   parser.parse(ARGV)
#   if !handled
#     STDERR.puts("Arguments didn't provide expected data")
#     puts parser
#   end
# end
