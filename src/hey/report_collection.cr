# load all the reports that come with hey...
require "./reports/*"
module Hey
  class ReportCollection

    def self.load_reports(reports_dir) : Array(Hey::Reports::Report)
      #reports = Array(Report).new
      reports = [Hey::Reports::InterruptsByHour.new(),
                 Hey::Reports::PeopleReport.new(),
                 Hey::Reports::Sparkline24.new()]
      if Dir.exists? reports_dir
        Dir.entries(reports_dir).each do |r|
          next if r == "." || r == ".."
          location = "#{reports_dir}/#{r}"
          response = `#{location} --info`

          begin
            rep = Hey::Reports::UserReport.from_json(response)
            rep.location = location
            # TODO: test if the db_version in rep
            # is compatable with the current db version
            existing = reports.index{|r| r.name == rep.name}
            if ! existing.nil?
              # user reports trump built-in reports
              reports[existing]=rep
            else
              reports << rep
            end
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
      end # end if Dir.exists? reports_dir
      reports
    end

    def self.list_reports(reports_dir)
      reports = load_reports(reports_dir)
      puts "Available reports:"
      # Question: should we note if there were no custom
      #           reports found?
      #           what about separating out user reports
      #           from built in?
      reports.sort_by(&.name).each do |rpt|
        puts "* #{rpt.name}"
        puts format_description(rpt.description)
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
          reports = ReportCollection.load_reports(reports_dir)
          reports.each do |r|
            if r.name == report_name
              r.run(config.db_path)
              break
            end
          end
        else
          ReportCollection.list_reports(reports_dir)
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
