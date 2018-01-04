require "option_parser"
require "json"
require "../config.cr"
config = Hey::Config.load
require "../*"
require "crystal_cli_graph"

module Hey
  module Reports
    class InterruptsByHour
      include Hey

      def run
        if !ENV.has_key? "DATABASE_URL"
          config = Hey::Config.load
        end
        hours, counts = generate_data()
        puts "Interrupts By Hour:"
        options = Hash(Symbol, Bool | Int32 | String? | Array(String)).new
        options[:column_labels] = hours
        options[:max_width] = 40
        options[:no_legend] = true
        g = CrystalCliGraph::Graph.new(counts, options)
        puts g.generate
      end

      def generate_data : Tuple(Array(String), Array(Int32))
        query = "select 
  strftime('%H', datetime(e.created_at, 'localtime')) hour, count(*) interrupts
from 
  events e 
group by 1
order by hour asc;"
        hours = Array(String).new
        counts = Array(Int32).new
        last_hour = -1
        Event.query(query) do |rs|
          # Event is irrelevent. It's just a subclass of Granite
          # with all the stuff set up
          rs.each do
            hour = rs.read(String)
            hour_i = hour.to_i
            count = Int32.new(rs.read(Int64))
            if hour_i - 1 == last_hour
              hours.push hour
              counts.push count
            else
              while hour_i > last_hour
                hour_i = last_hour + 1
                hours.push(hour_i > 9 ? hour_i.to_s : "0#{hour_i}")
                counts.push 0
                last_hour = hour_i
              end
              hours.push hour
              counts.push count
            end
            last_hour += 1
          end
        end
        return hours, counts
      end
    end
  end
end

### THIS GETS RUN AS A SEPARATE EXECUTABLE SO...

if File.basename(PROGRAM_NAME) == "interrupts_by_hour"
  handled = false
  parser = OptionParser.new do |parser|
    parser.banner = "Usage: --info"
    parser.on("-i", "--info", "Returns a JSON string describing this report") {
      handled = true
      data = Hash(String, String).new
      data["name"] = "interrupts_by_hour"
      data["description"] = \
        "Generates a graph of interruptions by hour."
      data["db_version"] = "2.0"

      json = String.build { |x| data.to_json(x) }
      puts json
    }
    parser.on("-d path", "--database=path", "Specifies the path to the SQLite
    DB") { |path|
      handled = true
      if File.exists?(path)
        # ENV["DATABASE_URL"]="sqlite3:#{path}"
        config.set_db_path(path.to_s)
        report = Hey::Reports::InterruptsByHour.new
        report.run
      else
        STDERR.puts("unable to find db at #{path}")
        exit 1
      end
    }
  end
  parser.parse(ARGV)
  if !handled
    STDERR.puts("Arguments didn't provide expected data")
    puts parser
  end
end
