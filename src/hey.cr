config = Hey::Config.load
config.running_hey
require "./hey/*" # no it doesn't make sense to require after using
# but the oter way around doesn't work because
# it doesn't have the db info before loading up
# Granite ORM subclasses.
require "sentence_options"
include Hey
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
    Hey::Event.command_description,
    Hey::Event.command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("tag",
    Hey::Tag.command_description,
    Hey::Tag.command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("tags", # plural
    Hey::Tag.tags_command_description,
    Hey::Tag.tags_command_proc(config)))
# parser.add_command(
# 	SentenceOptions::Command.new("people",
# 								 Person.people_command_description(),
# 								 Person.people_command_proc(config)))
parser.add_command(
  SentenceOptions::Command.new("report",
    Report.command_description,
    Report.command_proc(config)))
if !ENV.has_key? "IN_SPEC_TEST"
  if ARGV.size == 0
    STDERR.puts parser.usage
    exit 1
  end
  success = parser.parse(ARGV)
  if !success
    # they're trying to create an event with a person's name

  end
end

# def process_command(*args)
# 	if args.size > 0
# 		command = args.shift
# 		case command
# 		when "who"
# 			list_who(args.cdr)
# 		when "--version", "-v"
# 			version()
# 		when "help"
# 			help()
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
