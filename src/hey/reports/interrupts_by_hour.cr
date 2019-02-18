require "option_parser"
require "./report.cr"
require "../*"
require "crystal_cli_graph"

module Hey
  module Reports
    class InterruptsByHour < Hey::Reports::Report
      include Hey

      getter :name, :description, :db_version, :location
      def initialize()
        @name = "interrupts_by_hour"
        @description = "Generates a graph of interruptions by hour."
        @db_version = Hey::VERSION
        @location = nil.as(String?)
      end
      def run(db_path : String | Nil)
        # vvv should never be needed
        if db_path.nil? && !ENV.has_key? "DATABASE_URL"
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
          # Event is irrelevent. It's just a subclass of Sandstone
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
        if hours.size == 0
          #should only happen if run on a new database
          return interrupt_free_hours_and_counts()
        end
        return hours, counts
      end
      def interrupt_free_hours_and_counts() : Tuple(Array(String), Array(Int32))
        hours = Array(String).new
        counts = Array(Int32).new
        24.times do |hour|
          hours.push(hour > 9 ? hour.to_s : "0#{hour}")
          counts.push(0)
        end
        return hours, counts
      end
    end
  end
end

### You'd do this if it was running as a separated executable
# if File.basename(PROGRAM_NAME) == "interrupts_by_hour"
#   handled = false
#   parser = OptionParser.new do |parser|
#     parser.banner = "Usage: --info"
#     parser.on("-i", "--info", "Returns a JSON string describing this report") {
#       handled = true
#       data = Hash(String, String).new
#       data["name"] = "interrupts_by_hour"
#       data["description"] = \
#         "Generates a graph of interruptions by hour."
#       data["db_version"] = "2.0"
#
#       json = String.build { |x| data.to_json(x) }
#       puts json
#     }
#     parser.on("-d path", "--database=path", "Specifies the path to the SQLite
#     DB") { |path|
#       handled = true
#       if File.exists?(path)
#         # ENV["DATABASE_URL"]="sqlite3:#{path}"
#         config.set_db_path(path.to_s)
#         report = Hey::Reports::InterruptsByHour.new
#         report.run
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
