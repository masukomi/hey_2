require "json"
require "./interrupt_database"
class Config
	CONFIG_PATH="#{ENV["HOME"]}/.config/hey/config.json"
	getter db_path : String
	def initialize()
		@db_path = find_db_path()
	end
	def find_db_path() : String
		return "BULLSHIT PLACEHOLDER"
	end

	def self.load() : Config
		return Config.from_json(File.read(CONFIG_PATH))
	end

	def interrupt_database()
		return InterruptDatabase.new(self)
	end

	JSON.mapping({
		db_path:  {type: String, nilable: false}
	})
end
