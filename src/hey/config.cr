require "json"
require "sqlite3"
require "./interrupt_database"

module Hey
  class Config
    CONFIG_PATH = "#{ENV["HOME"]}/.config/hey/config.json"

    def initialize(new_db_path : String = Config.default_db_path)
      @db_path = new_db_path
      update_db_env(@db_path)
      ensure_dirs(@db_path)
    end


    def ensure_dirs(db_path : String)
      Dir.mkdir_p(reports_dir)

    end
    def db_path : String
      @db_path ||= default_db_path()
    end

    def reports_dir
      File.dirname(CONFIG_PATH) + "/reports"
    end

    def self.default_db_path : String
      File.dirname(CONFIG_PATH) + "/hey.db"
    end

    def set_db_path(new_db_path : String)
      @db_path = new_db_path
      update_db_env(@db_path.to_s)
    end

    def update_db_env(new_db_path : String)
      ENV["DATABASE_URL"] = "sqlite3:#{new_db_path}"
    end

    def save
      self.to_json(File.new(self.db_path))
    end

    def self.load : Config
      config = Config.from_json(File.read(CONFIG_PATH))
      path = config.db_path.to_s
      path = ENV["HEY_DB_PATH"].to_s if ENV.has_key?("HEY_DB_PATH")
      config.update_db_env(File.expand_path(path))

      config
    end

    # returns true if db install or upgrade is needed
    # otherwise returns false if all is good.
    def needs_installation_or_upgrade?() : Bool
      if got_db?
        if db_up_to_date?
          return false
        end
      end
      true
    end

    def got_db?
      return File.exists?(self.db_path.sub("sqlite3:", ""))
    end
    def db_up_to_date?(version : String = get_db_version()) : Bool
      version == Hey::VERSION
      # see comment in get_db_version
    end
    def get_db_version() : String
      version = "VERSION_NUMBER_HERE."
      # That seems odd, but it's what is stored in Hey::VERSION
      # until built with a specific version number
      # If you don't have a db you'll never get this far.
      # If you're developing we're assuming your db is correct
      begin
        DB.open self.db_path do |db|
          db.query "select major, minor, patch from versions order by id desc limit 1" do |rs|
            version = String.build do | str |
              rs.each do
                str << rs.read(Int64).to_s
                str << "."
              end
            end
          end
        end
      rescue
        #eat it.
      end
      version.chomp('.') # get rid of the trailing period
    end

    def running_hey : Bool
      ENV["RUNNING_HEY"] = "true"
      true
    end

    JSON.mapping({
      db_path: {type: String, nilable: false},
    })
  end
end
