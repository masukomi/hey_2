require "./hey/*"
require "option_parser"
# TODO replace OptionParser with something 
# more akin to the one we've got in the scheme version
# this is NOT sufficient



desired_action = :list
tags = [] of String
id = nil : String?
OptionParser.parse! do |parser|
	parser.banner= "Usage: hey [arguments]"
	parser.on("--list", "List recent interruptions"){
		desired_action = :list
	}
	parser.on("--tag", "Tag <id|last> <list of tags>"){
		tags = [] of String
		id = nil
		# TODO make the above not be bullshit
	}
end
