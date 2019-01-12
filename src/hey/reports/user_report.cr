module Hey
  module Reports
    # UserReports are executable files found in
    # ~/.config/hey/reports/
    # and are expect to support the standard report cli options
    class UserReport < Report
      JSON.mapping(
        name: String,
        description: String,
        db_version: String,
        location: {type: String, nilable: true}
      )
      def run(db_path : String | Nil)
        cli_string = "#{location} -d #{db_path}"
        response = `#{cli_string}`
        puts response
      end
    end
  end
end


