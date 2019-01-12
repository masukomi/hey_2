module Hey
  module Reports
    getter :name, :description, :db_version, :location
    abstract class Report
      abstract def run(db_path : String | Nil)
    end
  end
end

