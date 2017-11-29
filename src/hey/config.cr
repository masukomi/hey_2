require "json"
require "./interrupt_database"
module Hey
	class Config
		CONFIG_PATH="#{ENV["HOME"]}/.config/hey/config.json"
		getter :db_path
		def initialize()
			@db_path = default_db_path()
			update_db_env(@db_path)
		end
		
		def default_db_path() : String
			File.dirname(CONFIG_PATH) + "/hey.db"
		end
		def set_db_path(new_db_path : String)
			@db_path = new_db_path
			update_db_env(@db_path)
		end
		def update_db_env(db_path)
			ENV["DATABASE_URL"] = "sqlite3:#{db_path}"
		end

		def save()
			self.to_json(File.new(@db_path))
		end

		def self.load() : Config
			config = Config.from_json(File.read(CONFIG_PATH))
			config.update_db_env(config.db_path)
			config
		end

		JSON.mapping({
			db_path:  {type: String, nilable: true}
		})
	end
end
