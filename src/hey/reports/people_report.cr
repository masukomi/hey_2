require "option_parser"
require "json"
require "../config.cr"
require "sparker"
config = Hey::Config.load()
require "../*"
require "crystal_fmt"
module Hey
  module Reports
    class PeopleReport
      include Sparkline
      include Hey
      def run
        if ! ENV.has_key? "DATABASE_URL"
          config = Hey::Config.load()
        end
        data = generate_data()
        t = Table.new(data)
        puts "People, 14 days of activity, & tags"
        puts t.format
      end

      def generate_data() : Array(Array(String|Nil))
        sparker = Sparker.new(Sparkline::Sparker::TICKS_2)
        peeps = Person.all("ORDER BY name ASC")
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


    end
  end
end

handled = false
parser = OptionParser.new do |parser|
  parser.banner = "Usage: --info"
  parser.on("-i", "--info", "Returns a JSON string describing this report") {
    handled = true
    data = Hash(String, String).new
    data["name"] = "people_overview"
    data["description"] = \
"Generates a table with all the people you've
interacted with, their recent activity, and tags."
    data["db_version"] = "2.0"

    json = String.build{|x| data.to_json(x)}
    puts json
  }
  parser.on("-d path", "--database=path", "Specifies the path to the SQLite
  DB"){|path|
    handled = true
    if File.exists?(path)
      # ENV["DATABASE_URL"]="sqlite3:#{path}"
      config.set_db_path(path.to_s)
      pr = Hey::Reports::PeopleReport.new()
      pr.run
    else
      STDERR.puts("unable to find db at #{path}")
      exit 1
    end
  }
end
if !ENV.has_key?("RUNNING_HEY")
  parser.parse(ARGV)
  if ! handled
    STDERR.puts("Arguments didn't provide expected data")
    puts parser
  end
end
