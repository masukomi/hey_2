config = Hey::Config.load()
require "./hey/*" # no it doesn't make sense to require after using
                  # but the oter way around doesn't work because 
                  # it doesn't have the db info before loading up
                  # Granite ORM subclasses.
require "sentence_options"
# TODO: figure out where to put all these methods
# preferably break them down over multiple classes

# todo: that'll blow up if there isn't one
puts "db_path: #{config.db_path}"
puts "DATABASE_URL env: #{ENV["DATABASE_URL"]}"
puts "==================================================================="

parser = SentenceOptions::Parser.new(
"Usage: unlike many command line tools, hey uses 
        sentence-like commands to simplify interaction.")
parser.add_command(
	SentenceOptions::Command.new("list",
								 Hey::Event.command_description(),
								 Hey::Event.command_proc())
)
parser.add_command(
	SentenceOptions::Command.new("tag",
								 Hey::Tag.command_description(),
								 Hey::Tag.command_proc())

)
success = parser.parse(ARGV)
STDERR.puts parser.usage unless success


# def process_command(*args)
# 	if args.size > 0
# 		command = args.shift
# 		case command
# 		when "list"
# 			list_events(args.cdr)
# 		when "who"
# 			list_who(args.cdr)
# 		when "--version", "-v"
# 			version()
# 		when "help"
# 			help()
# 		when "tag"
# 			tag(args[1], args[2..-1])
# 		when "tags"
# 			list_tags()
# 		when "comment"
# 			comment(args[1], args[2..-1].join(" "))
# 		when "delete"
# 			delete_entry(args[1])
# 		when "kill"
# 			kill(args[1], args[2..-1])
# 		when "graph"
# 			graph(args[1..-1])
# 		else
# 			STDERR.puts("Unknown command #{command}")
# 		end
# 	else
# 		list_events()
# 	end
# end
