require "json"
require "sqlite3"
require "./interrupt_database"

#TODO: The config.json code is currently commented out
# and should be re-enabled to facilitate testing without
# wiping out or polluting your real db


module Hey
  class Config
    @@singleton_me = nil.as(Config?)
    CONFIG_PATH = "#{ENV["HOME"]}/.config/hey/config.json"
    ### CLASS METHODS
    DEFAULT_DB_PATH=File.dirname(CONFIG_PATH) + "/hey.db"

    def self.load : Config
      if !@@singleton_me.nil?
        @@singleton_me.as(Config)
      else
        # if File.exists?  CONFIG_PATH
        #   config = Config.from_json(File.read(CONFIG_PATH))
        # else
          config = Config.new()
        # end
        path = config.db_path.to_s
        path = ENV["HEY_DB_PATH"].to_s if ENV.has_key?("HEY_DB_PATH")
        config.update_db_env(File.expand_path(path))

        @@singleton_me = config
        @@singleton_me.as(Config)
      end
    end
    ### END CLASS METHODS

    # INSTANCE METHODS


    def initialize(new_db_path : String = DEFAULT_DB_PATH)
      @db_path_string = new_db_path
      update_db_env(@db_path_string)
      ensure_dirs(@db_path_string)
    end


    def ensure_dirs(db_path : String)
      Dir.mkdir_p(reports_dir)
    end
    def db_path : String
      if ! @db_path_string
        @db_path_string = DEFAULT_DB_PATH
      end
      @db_path_string 
    end

    def reports_dir
      File.dirname(CONFIG_PATH) + "/reports"
    end

    def set_db_path(new_db_path : String)
      @db_path_string = new_db_path
      update_db_env(@db_path_string.to_s)
    end

    def update_db_env(new_db_path : String)
      ENV["DATABASE_URL"] = "sqlite3:#{new_db_path}"
    end

    # def save
    #   self.to_json(File.new(self.db_path))
    # end

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

    def got_db?() : Bool
      filesystem_db_path = self.db_path.sub("sqlite3:", "")
      return File.exists?(filesystem_db_path)
    end
    def db_up_to_date?(version : String = get_db_version()) : Bool
      version == Hey::VERSION || version == "VERSION_NUMBER_HERE" # <-- dev version
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

    # JSON.mapping({
    #   db_path_string: {type: String, nilable: false},
    # })
  end
end
