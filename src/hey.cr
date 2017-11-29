require "./hey/*"
require "./sentence_options/*"

# TODO: figure out where to put all these methods
# preferably break them down over multiple classes


parser = SentenceOptions::Parser.new()
parser.add_command(
	SentenceOptions::Command.new("list",
				
				"  hey list [number] " \
				"    lists recent events" \
				"    defaults to 25",
				
				Proc(Array(String), Bool).new{ |args|
					limit = 25
					if args.size > 0
						limit = args.first.to_i
					end
					Hey::Event.list_recent(limit)
					true
				})
)
parser.parse(ARGV)


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
