module Hey
  class Report
    JSON.mapping(
      name: String,
      description: String,
      db_version: String,
      location: {type: String, nilable: true},
    )

    def run(db_path : String | Nil)
      cli_string = "#{location} -d #{db_path}"
      response = `#{cli_string}`
      puts response
    end

    def self.load_reports(reports_dir) : Array(Report)
      reports = Array(Report).new
      Dir.entries(reports_dir).each do |r|
        next if r == "." || r == ".."
        location = "#{reports_dir}/#{r}"
        response = `#{location} --info`

        begin
          rep = Report.from_json(response)
          rep.location = location
          # TODO: test if the db_version in rep
          # is compatable with the current db version

          reports << rep
        rescue ex
          temp = JSON.parse(response) rescue nil
          if temp
            STDERR.puts("JSON is not as expected from #{location}")
            STDERR.puts(ex.message)
          else
            STDERR.puts("Unexpected response from #{r}:\n\t#{response}")
          end
        end
      end
      reports
    end

    def self.list_reports(reports_dir)
      if Dir.exists? reports_dir
        reports = load_reports(reports_dir)
        puts "Available reports:"
        if reports.size > 0
          reports.each do |rpt|
            puts "* #{rpt.name}"
            puts format_description(rpt.description)
          end
        else
          puts "NONE: no report generators were found in #{reports_dir}"
        end
      else
        STDERR.puts("reports directory does not exist. Please create it
at #{reports_dir} and add some reports")
      end
    end

    private def self.format_description(description) : String
      response = String.build { |str|
        description.split("\n").each do |d|
          str << "\t"
          str << d
          str << "\n"
        end
      }
    end

    # -----------------------------------
    def self.command_proc(config : Hey::Config) : Proc(Array(String), Bool)
      Proc(Array(String), Bool).new { |args|
        reports_dir = config.reports_dir
        if args.size > 0
          report_name = args[0].downcase
          reports = Report.load_reports(reports_dir)
          reports.each do |r|
            if r.name == report_name
              r.run(config.db_path)
              break
            end
          end
        else
          Report.list_reports(reports_dir)
        end
        true
      }
    end

    def self.command_description : String
      "  hey report [report_name]
     lists available reports
     or runs them when specified"
    end
  end
end
