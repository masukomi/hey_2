require "json"
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
      self.to_json(File.new(@db_path))
    end

    def self.load : Config
      config = Config.from_json(File.read(CONFIG_PATH))
      if !ENV.has_key? "HEY_DB_PATH"
        config.update_db_env(config.db_path.to_s)
      else
        config.update_db_env(ENV["HEY_DB_PATH"].to_s)
      end
      config
    end

    def running_hey : Bool
      ENV["RUNNING_HEY"] = "true"
      true
    end

    JSON.mapping({
      db_path: {type: String, nilable: true},
    })
  end
end
