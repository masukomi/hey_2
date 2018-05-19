require "option_parser"
require "json"
require "../config.cr"
config = Hey::Config.load
require "../*"
require "sparker"

module Hey
  module Reports
    class Sparkline24
      include Hey
      include Sparkline

      def run
        if !ENV.has_key? "DATABASE_URL"
          config = Hey::Config.load
        end
        hours, counts = generate_data()
        sparker = Sparker.new(Sparker::TICKS_2)
        puts sparker.generate(counts)
      end

      def generate_data : Tuple(Array(String), Array(Int32))
        # stolen from Sparkline24 report
        start_time = 24.hours.ago
        query = "select
  strftime('%H', datetime(e.created_at, 'localtime')) hour, count(*) interrupts
from
  events e
where e.created_at >= '#{start_time.to_s("%Y-%m-%d %H:00")}'
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
        if hours.size == 0
          return interrupt_free_hours_and_counts(start_time)
        end
        return hours, counts
      end
      def interrupt_free_hours_and_counts(start_time : Time ) : Tuple(Array(String), Array(Int32))
        hours = Array(String).new
        counts = Array(Int32).new
        hour = start_time.hour
        24.times do |t|
          now = hour + t
          if now > 23
            now -= 24
          end
          hours.push(now > 9 ? now.to_s : "0#{now}")
          counts.push(0)
        end
        return hours, counts
      end
    end
  end
end

### THIS GETS RUN AS A SEPARATE EXECUTABLE SO...

if File.basename(PROGRAM_NAME) == "sparkline_24"
  handled = false
  parser = OptionParser.new do |parser|
    parser.banner = "Usage: --info"
    parser.on("-i", "--info", "Returns a JSON string describing this report") {
      handled = true
      data = Hash(String, String).new
      data["name"] = "sparkline_24"
      data["description"] = \
        "Generates a sparkline graph of interrupts within the past 24hrs"
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
        report = Hey::Reports::Sparkline24.new
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
