require "readline"

module Hey::CliTool
	def ask_until_acceptable(message,
							valid_responses : Array(String)) : String
		input = Readline.readline(message).to_s
		if valid_responses.includes? input
			return input
		end
		return ask_until_acceptable(message, valid_responses)
	end
	def ask_until_acceptable(message,
								tester : Proc(String, Bool)) : String
		input = Readline.readline(message).to_s
		if tester.call(input)
			return input
		end
		return ask_until_acceptable(message, tester)
	end


	def ask_yes_no(message) : Bool
		response = ask_until_acceptable((message + " [y/n]: "),
						 	 ["Y", "y", "N", "n"])
		if ["Y", "y"].includes? response
			return true
		end
		return false
	end

	def ask_for_non_optional_input(message : String) : String
		input = Readline.readline(message).to_s
		if input.match(/^\s*$/)
			puts "Please try again. That wasn't optional."
			return ask_for_non_optional_input(message)
		end
		return input
	end

	def convert_comma_list_to_array(list : String) : Array(String)
		return list.to_s.split(/\s*,\s*/).select{|x| !x.nil? && x != ""}
		# i don't trust them to follow instructions
	end

	def get_called_from() : String
		called_from = File.expand_path(".").to_s
	end

	def get_stdin_from_tty()
		if ! STDIN.tty?
			STDIN.reopen(File.open("/dev/tty", "a+"))
		end
	end
end
